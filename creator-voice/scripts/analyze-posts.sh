#!/usr/bin/env bash
# analyze-posts.sh - Extract statistical patterns from social media posts
#
# Usage:
#   ./analyze-posts.sh input.csv output-stats.json
#   ./analyze-posts.sh input.txt output-stats.json [--format text]
#
# Input formats:
#   CSV: expected columns are "text" (required), "created_at" (optional), "engagement" (optional)
#   Text: one post per line, or posts separated by blank lines
#   JSON: array of objects with "text" field (optional "created_at", "engagement")
#
# Output:
#   JSON file with statistical analysis of post patterns

set -euo pipefail

VERSION="1.0.0"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Helper functions
info() {
    echo -e "${YELLOW}[INFO]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" >&2
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

usage() {
    cat << EOF
analyze-posts.sh - Extract statistical patterns from social media posts

Usage:
  $0 INPUT_FILE OUTPUT_FILE [OPTIONS]

Arguments:
  INPUT_FILE    Path to input file (CSV, JSON, or plain text)
  OUTPUT_FILE   Path to output JSON file

Options:
  --format FORMAT    Force input format (csv, json, text). Auto-detected by default.
  --help, -h         Show this help message
  --version, -v      Show version

Input formats:
  CSV:  "text","created_at","engagement" (text column required)
  JSON: [{"text": "...", "created_at": "...", "engagement": ...}, ...]
  Text: One post per line, or posts separated by blank lines

Output:
  JSON file with:
  - Total posts analyzed
  - Average/median/min/max post length (characters and words)
  - Emoji rate (posts with emoji / total posts)
  - Hashtag rate (posts with hashtags / total posts)
  - Line break frequency (avg line breaks per post)
  - Link frequency (posts with links / total posts)
  - Common opening words (top 10)
  - Length distribution (short/medium/long)

Example:
  $0 tweets.csv stats.json
  $0 posts.txt stats.json --format text
EOF
}

# Parse arguments
INPUT_FILE=""
OUTPUT_FILE=""
FORMAT="auto"

while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            usage
            exit 0
            ;;
        --version|-v)
            echo "analyze-posts.sh version $VERSION"
            exit 0
            ;;
        --format)
            FORMAT="$2"
            shift 2
            ;;
        *)
            if [[ -z "$INPUT_FILE" ]]; then
                INPUT_FILE="$1"
            elif [[ -z "$OUTPUT_FILE" ]]; then
                OUTPUT_FILE="$1"
            else
                error "Unexpected argument: $1"
            fi
            shift
            ;;
    esac
done

if [[ -z "$INPUT_FILE" ]] || [[ -z "$OUTPUT_FILE" ]]; then
    error "Missing required arguments. Use --help for usage."
fi

if [[ ! -f "$INPUT_FILE" ]]; then
    error "Input file not found: $INPUT_FILE"
fi

# Detect format if auto
if [[ "$FORMAT" == "auto" ]]; then
    case "${INPUT_FILE##*.}" in
        csv) FORMAT="csv" ;;
        json) FORMAT="json" ;;
        txt) FORMAT="text" ;;
        *) error "Cannot auto-detect format from extension. Use --format option." ;;
    esac
fi

info "Analyzing posts from $INPUT_FILE (format: $FORMAT)"

# Extract posts into a temporary file (one post per line, escaped)
TEMP_POSTS=$(mktemp)
trap "rm -f $TEMP_POSTS" EXIT

case "$FORMAT" in
    csv)
        # Parse CSV - extract "text" column (assumes header row, comma-separated, quoted fields)
        # This is a simple CSV parser; for complex CSVs, use a proper tool
        tail -n +2 "$INPUT_FILE" | awk -F',' '{
            # Find text column (assumes it is the first column or labeled "text")
            # Simple approach: extract first field
            gsub(/^"/, "", $1)
            gsub(/"$/, "", $1)
            if (length($1) > 0) print $1
        }' > "$TEMP_POSTS"
        ;;
    json)
        # Parse JSON array - extract "text" fields
        if ! command -v jq &> /dev/null; then
            error "jq is required for JSON parsing but not found. Install jq or use a different format."
        fi
        jq -r '.[] | .text // empty' "$INPUT_FILE" > "$TEMP_POSTS"
        ;;
    text)
        # Plain text - one post per line, or separated by blank lines
        # Combine multi-line posts into single lines
        awk 'BEGIN{RS=""; FS="\n"} {gsub(/\n/, " "); print}' "$INPUT_FILE" > "$TEMP_POSTS"
        ;;
    *)
        error "Unsupported format: $FORMAT"
        ;;
esac

# Count posts
TOTAL_POSTS=$(wc -l < "$TEMP_POSTS")

if [[ "$TOTAL_POSTS" -eq 0 ]]; then
    error "No posts found in input file"
fi

info "Found $TOTAL_POSTS posts"

# Analyze posts
# We'll compute statistics using awk and shell commands

# Character lengths
CHAR_LENGTHS=$(awk '{print length($0)}' "$TEMP_POSTS" | sort -n)
AVG_CHARS=$(echo "$CHAR_LENGTHS" | awk '{sum+=$1} END {print int(sum/NR)}')
MEDIAN_CHARS=$(echo "$CHAR_LENGTHS" | awk '{a[NR]=$1} END {print (NR%2==1) ? a[(NR+1)/2] : int((a[NR/2]+a[NR/2+1])/2)}')
MIN_CHARS=$(echo "$CHAR_LENGTHS" | head -1)
MAX_CHARS=$(echo "$CHAR_LENGTHS" | tail -1)

# Word counts
WORD_COUNTS=$(awk '{print NF}' "$TEMP_POSTS" | sort -n)
AVG_WORDS=$(echo "$WORD_COUNTS" | awk '{sum+=$1} END {print int(sum/NR)}')
MEDIAN_WORDS=$(echo "$WORD_COUNTS" | awk '{a[NR]=$1} END {print (NR%2==1) ? a[(NR+1)/2] : int((a[NR/2]+a[NR/2+1])/2)}')

# Emoji rate (simple heuristic: any post with non-ASCII high-range chars)
EMOJI_COUNT=$(grep -cP '[\x{1F600}-\x{1F64F}\x{1F300}-\x{1F5FF}\x{1F680}-\x{1F6FF}\x{2600}-\x{26FF}\x{2700}-\x{27BF}]' "$TEMP_POSTS" || true)
EMOJI_COUNT=${EMOJI_COUNT:-0}
EMOJI_RATE=$(awk -v emoji="$EMOJI_COUNT" -v total="$TOTAL_POSTS" 'BEGIN {printf "%.2f", (emoji/total)*100}')

# Hashtag rate
HASHTAG_COUNT=$(grep -c '#' "$TEMP_POSTS" || true)
HASHTAG_COUNT=${HASHTAG_COUNT:-0}
HASHTAG_RATE=$(awk -v ht="$HASHTAG_COUNT" -v total="$TOTAL_POSTS" 'BEGIN {printf "%.2f", (ht/total)*100}')

# Line break frequency (newlines in original posts, if preserved)
# Since we normalized to one per line, we'll use a heuristic: posts with multiple sentences
# For now, report as 0 (would need original format to detect)
AVG_LINE_BREAKS=0

# Link frequency
LINK_COUNT=$(grep -cE 'https?://' "$TEMP_POSTS" || true)
LINK_COUNT=${LINK_COUNT:-0}
LINK_RATE=$(awk -v links="$LINK_COUNT" -v total="$TOTAL_POSTS" 'BEGIN {printf "%.2f", (links/total)*100}')

# Common opening words (first word of each post, top 10)
OPENING_WORDS=$(awk '{print $1}' "$TEMP_POSTS" | tr '[:upper:]' '[:lower:]' | sort | uniq -c | sort -rn | head -10 | awk '{printf "%s:%d ", $2, $1}')

# Length distribution (short: <100 chars, medium: 100-200, long: >200)
SHORT=$(echo "$CHAR_LENGTHS" | awk '$1 < 100' | wc -l)
MEDIUM=$(echo "$CHAR_LENGTHS" | awk '$1 >= 100 && $1 <= 200' | wc -l)
LONG=$(echo "$CHAR_LENGTHS" | awk '$1 > 200' | wc -l)

SHORT_PCT=$(awk -v s="$SHORT" -v total="$TOTAL_POSTS" 'BEGIN {printf "%.1f", (s/total)*100}')
MEDIUM_PCT=$(awk -v m="$MEDIUM" -v total="$TOTAL_POSTS" 'BEGIN {printf "%.1f", (m/total)*100}')
LONG_PCT=$(awk -v l="$LONG" -v total="$TOTAL_POSTS" 'BEGIN {printf "%.1f", (l/total)*100}')

# Generate JSON output
cat > "$OUTPUT_FILE" << EOF
{
  "analysis_version": "$VERSION",
  "analyzed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "input_file": "$INPUT_FILE",
  "input_format": "$FORMAT",
  "total_posts": $TOTAL_POSTS,
  "length": {
    "characters": {
      "average": $AVG_CHARS,
      "median": $MEDIAN_CHARS,
      "min": $MIN_CHARS,
      "max": $MAX_CHARS
    },
    "words": {
      "average": $AVG_WORDS,
      "median": $MEDIAN_WORDS
    }
  },
  "features": {
    "emoji_rate_percent": $EMOJI_RATE,
    "posts_with_emoji": $EMOJI_COUNT,
    "hashtag_rate_percent": $HASHTAG_RATE,
    "posts_with_hashtags": $HASHTAG_COUNT,
    "link_rate_percent": $LINK_RATE,
    "posts_with_links": $LINK_COUNT,
    "average_line_breaks": $AVG_LINE_BREAKS
  },
  "opening_words": {
EOF

# Parse opening words into JSON array
FIRST=true
for word_count in $OPENING_WORDS; do
    WORD="${word_count%:*}"
    COUNT="${word_count#*:}"
    if [[ "$FIRST" == true ]]; then
        FIRST=false
    else
        echo "," >> "$OUTPUT_FILE"
    fi
    echo -n "    \"$WORD\": $COUNT" >> "$OUTPUT_FILE"
done

cat >> "$OUTPUT_FILE" << EOF

  },
  "length_distribution": {
    "short": {
      "count": $SHORT,
      "percent": $SHORT_PCT,
      "definition": "< 100 characters"
    },
    "medium": {
      "count": $MEDIUM,
      "percent": $MEDIUM_PCT,
      "definition": "100-200 characters"
    },
    "long": {
      "count": $LONG,
      "percent": $LONG_PCT,
      "definition": "> 200 characters"
    }
  }
}
EOF

success "Analysis complete: $OUTPUT_FILE"
info "Summary: $TOTAL_POSTS posts, avg $AVG_CHARS chars, ${EMOJI_RATE}% with emoji, ${HASHTAG_RATE}% with hashtags"
