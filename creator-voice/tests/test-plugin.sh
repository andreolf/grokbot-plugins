#!/usr/bin/env bash
# test-plugin.sh - Test creator-voice plugin functionality

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
TEST_ROOT="/tmp/creator-voice-test-$$"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() {
    echo -e "${GREEN}✓ $1${NC}"
}

fail() {
    echo -e "${RED}✗ $1${NC}"
    exit 1
}

info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

section() {
    echo
    echo "========================================="
    echo "$1"
    echo "========================================="
}

cleanup() {
    info "Cleaning up test environment..."
    rm -rf "$TEST_ROOT"
}

trap cleanup EXIT

# Setup
section "Setting up test environment"

mkdir -p "$TEST_ROOT"
info "Test root: $TEST_ROOT"

# Test 1: Test analyze-posts script with CSV
section "Test 1: analyze-posts.sh with CSV input"

CSV_INPUT="$PLUGIN_DIR/tests/fixtures/sample-posts.csv"
CSV_OUTPUT="$TEST_ROOT/stats-csv.json"

if [ ! -f "$CSV_INPUT" ]; then
    fail "Test fixture not found: $CSV_INPUT"
fi

"$PLUGIN_DIR/scripts/analyze-posts.sh" "$CSV_INPUT" "$CSV_OUTPUT"

if [ ! -f "$CSV_OUTPUT" ]; then
    fail "analyze-posts.sh did not create output file"
fi

# Validate JSON output
if ! jq empty "$CSV_OUTPUT" 2>/dev/null; then
    fail "analyze-posts.sh output is not valid JSON"
fi

# Check required fields
if ! jq -e '.total_posts' "$CSV_OUTPUT" >/dev/null; then
    fail "Output missing required field: total_posts"
fi

TOTAL_POSTS=$(jq -r '.total_posts' "$CSV_OUTPUT")
if [ "$TOTAL_POSTS" -ne 7 ]; then
    fail "Expected 7 posts, got $TOTAL_POSTS"
fi

pass "analyze-posts.sh (CSV): processed $TOTAL_POSTS posts"

# Test 2: Test analyze-posts script with JSON
section "Test 2: analyze-posts.sh with JSON input"

JSON_INPUT="$PLUGIN_DIR/tests/fixtures/sample-posts.json"
JSON_OUTPUT="$TEST_ROOT/stats-json.json"

if [ ! -f "$JSON_INPUT" ]; then
    fail "Test fixture not found: $JSON_INPUT"
fi

if ! command -v jq &> /dev/null; then
    info "jq not installed, skipping JSON test"
else
    "$PLUGIN_DIR/scripts/analyze-posts.sh" "$JSON_INPUT" "$JSON_OUTPUT"

    if [ ! -f "$JSON_OUTPUT" ]; then
        fail "analyze-posts.sh did not create output file for JSON"
    fi

    TOTAL_POSTS_JSON=$(jq -r '.total_posts' "$JSON_OUTPUT")
    if [ "$TOTAL_POSTS_JSON" -ne 7 ]; then
        fail "Expected 7 posts from JSON, got $TOTAL_POSTS_JSON"
    fi

    pass "analyze-posts.sh (JSON): processed $TOTAL_POSTS_JSON posts"
fi

# Test 3: Test analyze-posts script with text
section "Test 3: analyze-posts.sh with text input"

TXT_INPUT="$PLUGIN_DIR/tests/fixtures/sample-posts.txt"
TXT_OUTPUT="$TEST_ROOT/stats-txt.json"

if [ ! -f "$TXT_INPUT" ]; then
    fail "Test fixture not found: $TXT_INPUT"
fi

"$PLUGIN_DIR/scripts/analyze-posts.sh" "$TXT_INPUT" "$TXT_OUTPUT"

if [ ! -f "$TXT_OUTPUT" ]; then
    fail "analyze-posts.sh did not create output file for text"
fi

TOTAL_POSTS_TXT=$(jq -r '.total_posts' "$TXT_OUTPUT")
if [ "$TOTAL_POSTS_TXT" -ne 7 ]; then
    fail "Expected 7 posts from text, got $TOTAL_POSTS_TXT"
fi

pass "analyze-posts.sh (text): processed $TOTAL_POSTS_TXT posts"

# Test 4: Verify output statistics
section "Test 4: Verify output statistics"

info "Checking calculated statistics..."

# Check that averages are reasonable
AVG_CHARS=$(jq -r '.length.characters.average' "$CSV_OUTPUT")
if [ "$AVG_CHARS" -lt 30 ] || [ "$AVG_CHARS" -gt 200 ]; then
    fail "Average character length seems wrong: $AVG_CHARS"
fi
pass "Average character length: $AVG_CHARS (reasonable)"

# Check that emoji rate exists and is a percentage
EMOJI_RATE=$(jq -r '.features.emoji_rate_percent' "$CSV_OUTPUT")
if ! echo "$EMOJI_RATE" | grep -qE '^[0-9]+(\.[0-9]+)?$'; then
    fail "Emoji rate is not a valid number: $EMOJI_RATE"
fi
pass "Emoji rate: ${EMOJI_RATE}%"

# Check hashtag rate
HASHTAG_RATE=$(jq -r '.features.hashtag_rate_percent' "$CSV_OUTPUT")
if ! echo "$HASHTAG_RATE" | grep -qE '^[0-9]+(\.[0-9]+)?$'; then
    fail "Hashtag rate is not a valid number: $HASHTAG_RATE"
fi
pass "Hashtag rate: ${HASHTAG_RATE}%"

# Check link rate
LINK_RATE=$(jq -r '.features.link_rate_percent' "$CSV_OUTPUT")
if ! echo "$LINK_RATE" | grep -qE '^[0-9]+(\.[0-9]+)?$'; then
    fail "Link rate is not a valid number: $LINK_RATE"
fi
pass "Link rate: ${LINK_RATE}%"

# Check length distribution
SHORT=$(jq -r '.length_distribution.short.count' "$CSV_OUTPUT")
MEDIUM=$(jq -r '.length_distribution.medium.count' "$CSV_OUTPUT")
LONG=$(jq -r '.length_distribution.long.count' "$CSV_OUTPUT")

TOTAL_DIST=$((SHORT + MEDIUM + LONG))
if [ "$TOTAL_DIST" -ne "$TOTAL_POSTS" ]; then
    fail "Length distribution sum ($TOTAL_DIST) doesn't match total posts ($TOTAL_POSTS)"
fi
pass "Length distribution: short=$SHORT, medium=$MEDIUM, long=$LONG"

# Test 5: Check opening words
section "Test 5: Check opening words analysis"

OPENING_WORDS=$(jq -r '.opening_words | keys | .[]' "$CSV_OUTPUT" | head -5)
if [ -z "$OPENING_WORDS" ]; then
    fail "No opening words found"
fi

info "Top opening words:"
for word in $OPENING_WORDS; do
    COUNT=$(jq -r ".opening_words.\"$word\"" "$CSV_OUTPUT")
    info "  $word: $COUNT"
done
pass "Opening words analysis complete"

# Test 6: Example voice profile validation
section "Test 6: Validate example voice profile"

VOICE_PROFILE="$PLUGIN_DIR/examples/voice-profiles/example-tech-creator.md"

if [ ! -f "$VOICE_PROFILE" ]; then
    fail "Example voice profile not found"
fi

# Check for required sections (heuristic)
if ! grep -q "## Tone and Personality" "$VOICE_PROFILE"; then
    fail "Voice profile missing 'Tone and Personality' section"
fi

if ! grep -q "## Hook Patterns" "$VOICE_PROFILE"; then
    fail "Voice profile missing 'Hook Patterns' section"
fi

if ! grep -q "## Do's" "$VOICE_PROFILE"; then
    fail "Voice profile missing 'Do's' section"
fi

if ! grep -q "## Don'ts" "$VOICE_PROFILE"; then
    fail "Voice profile missing 'Don'ts' section"
fi

pass "Example voice profile has required sections"

# Test 7: Skills frontmatter validation
section "Test 7: Validate all skills frontmatter"

SKILLS_DIR="$PLUGIN_DIR/skills"
EXPECTED_SKILLS=("voice-profile" "humanize" "x-post" "x-thread" "changelog-to-thread" "video-to-posts")

for skill in "${EXPECTED_SKILLS[@]}"; do
    SKILL_FILE="$SKILLS_DIR/$skill/SKILL.md"
    
    if [ ! -f "$SKILL_FILE" ]; then
        fail "Skill file not found: $skill"
    fi
    
    # Extract frontmatter
    FRONTMATTER=$(awk '/^---$/{if(++n==2)exit;next}n' "$SKILL_FILE")
    
    # Check name matches
    FM_NAME=$(echo "$FRONTMATTER" | grep "^name:" | sed 's/^name: *//')
    if [ "$FM_NAME" != "$skill" ]; then
        fail "Skill $skill: name mismatch in frontmatter (expected $skill, got $FM_NAME)"
    fi
    
    # Check description exists and is not empty
    if ! echo "$FRONTMATTER" | grep -q "^description:"; then
        fail "Skill $skill: missing description"
    fi
    
    # Extract description (simple: get the line starting with description:)
    DESCRIPTION=$(echo "$FRONTMATTER" | grep "^description:" | sed 's/^description: *//')
    if [ -z "$DESCRIPTION" ]; then
        fail "Skill $skill: description is empty"
    fi
    
    pass "Skill $skill: frontmatter valid"
done

pass "All skills validated"

# Final summary
section "Test Summary"

info "Tests completed:"
info "  ✓ analyze-posts.sh with CSV, JSON, and text"
info "  ✓ Output statistics validation"
info "  ✓ Example voice profile structure"
info "  ✓ All skills frontmatter"
info "  ✓ Processed $TOTAL_POSTS test posts"

section "All Tests Passed!"
echo
echo "Plugin is functional and ready for use."
echo
