#!/usr/bin/env bash
# validate-plugin.sh - Validate skill-vetter plugin structure and frontmatter

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
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

echo "=== Validating Skill Vetter Plugin ==="
echo "Plugin directory: $PLUGIN_DIR"
echo

# Test 1: plugin.json exists
if [ ! -f "$PLUGIN_DIR/.cursor-plugin/plugin.json" ]; then
    fail ".cursor-plugin/plugin.json not found"
fi
pass "plugin.json exists"

# Test 2: plugin.json is valid JSON
if ! jq empty "$PLUGIN_DIR/.cursor-plugin/plugin.json" 2>/dev/null; then
    fail "plugin.json is not valid JSON"
fi
pass "plugin.json is valid JSON"

# Test 3: Required fields present
PLUGIN_JSON="$PLUGIN_DIR/.cursor-plugin/plugin.json"

if ! jq -e '.name' "$PLUGIN_JSON" >/dev/null; then
    fail "plugin.json missing required field: name"
fi
pass "plugin.json has required 'name' field"

# Test 4: name matches pattern
NAME=$(jq -r '.name' "$PLUGIN_JSON")
if ! echo "$NAME" | grep -qE '^[a-z0-9]([a-z0-9.-]*[a-z0-9])?$'; then
    fail "name '$NAME' doesn't match pattern (must be kebab-case)"
fi
pass "name '$NAME' matches kebab-case pattern"

# Test 5: author is object with name
if ! jq -e '.author.name' "$PLUGIN_JSON" >/dev/null; then
    fail "plugin.json missing author.name"
fi
pass "author.name present"

# Test 6: No additionalProperties (only allowed fields)
ALLOWED_FIELDS="name displayName description version minClientVersions author publisher homepage repository license logo keywords category tags commands agents skills rules hooks variables mcpServers"
ACTUAL_FIELDS=$(jq -r 'keys | .[]' "$PLUGIN_JSON")

for field in $ACTUAL_FIELDS; do
    if ! echo "$ALLOWED_FIELDS" | grep -qw "$field"; then
        fail "Unexpected field in plugin.json: $field (schema has additionalProperties: false)"
    fi
done
pass "All plugin.json fields are allowed by schema"

# Test 7: Validate skills path exists
SKILLS_PATH=$(jq -r '.skills // "skills/"' "$PLUGIN_JSON")
SKILLS_PATH="${SKILLS_PATH%/}"

if [ ! -d "$PLUGIN_DIR/$SKILLS_PATH" ]; then
    fail "Skills directory not found: $SKILLS_PATH"
fi
pass "Skills directory exists: $SKILLS_PATH"

# Test 8: Each skill has valid SKILL.md
echo
info "Validating skill frontmatter..."

SKILL_COUNT=0
for skill_dir in "$PLUGIN_DIR/$SKILLS_PATH"/*/; do
    if [ ! -d "$skill_dir" ]; then
        continue
    fi
    
    SKILL_NAME=$(basename "$skill_dir")
    SKILL_FILE="$skill_dir/SKILL.md"
    
    if [ ! -f "$SKILL_FILE" ]; then
        fail "Skill $SKILL_NAME missing SKILL.md"
    fi
    
    # Extract frontmatter
    if ! head -20 "$SKILL_FILE" | grep -q "^---$"; then
        fail "Skill $SKILL_NAME: SKILL.md missing frontmatter"
    fi
    
    FRONTMATTER=$(awk '/^---$/{if(++n==2)exit;next}n' "$SKILL_FILE")
    
    if ! echo "$FRONTMATTER" | grep -q "^name:"; then
        fail "Skill $SKILL_NAME: missing 'name' in frontmatter"
    fi
    
    if ! echo "$FRONTMATTER" | grep -q "^description:"; then
        fail "Skill $SKILL_NAME: missing 'description' in frontmatter"
    fi
    
    # Check name matches directory
    FM_NAME=$(echo "$FRONTMATTER" | grep "^name:" | sed 's/^name: *//')
    if [ "$FM_NAME" != "$SKILL_NAME" ]; then
        fail "Skill $SKILL_NAME: frontmatter name '$FM_NAME' doesn't match directory"
    fi
    
    pass "Skill $SKILL_NAME: valid"
    SKILL_COUNT=$((SKILL_COUNT + 1))
done

pass "All $SKILL_COUNT skills validated"

# Test 9: README exists
if [ ! -f "$PLUGIN_DIR/README.md" ]; then
    fail "README.md not found"
fi
pass "README.md exists"

# Test 10: LICENSE exists
if [ ! -f "$PLUGIN_DIR/LICENSE" ]; then
    fail "LICENSE not found"
fi
pass "LICENSE exists"

# Test 11: CHANGELOG exists
if [ ! -f "$PLUGIN_DIR/CHANGELOG.md" ]; then
    fail "CHANGELOG.md not found"
fi
pass "CHANGELOG.md exists"

# Test 12: vet.sh script exists and is executable
if [ ! -f "$PLUGIN_DIR/scripts/vet.sh" ]; then
    fail "scripts/vet.sh not found"
fi
if [ ! -x "$PLUGIN_DIR/scripts/vet.sh" ]; then
    fail "scripts/vet.sh is not executable"
fi
pass "vet.sh exists and is executable"

# Test 13: Test fixtures exist
if [ ! -d "$PLUGIN_DIR/tests/fixtures/good" ]; then
    fail "Good test fixtures directory not found"
fi
if [ ! -d "$PLUGIN_DIR/tests/fixtures/bad" ]; then
    fail "Bad test fixtures directory not found"
fi

GOOD_COUNT=$(find "$PLUGIN_DIR/tests/fixtures/good" -name "SKILL.md" | wc -l)
BAD_COUNT=$(find "$PLUGIN_DIR/tests/fixtures/bad" -name "SKILL.md" | wc -l)

if [ "$GOOD_COUNT" -lt 2 ]; then
    fail "Not enough good test fixtures (need at least 2, found $GOOD_COUNT)"
fi
if [ "$BAD_COUNT" -lt 5 ]; then
    fail "Not enough bad test fixtures (need at least 5, found $BAD_COUNT)"
fi

pass "Test fixtures exist ($GOOD_COUNT good, $BAD_COUNT bad)"

# Test 14: Check for unsafe patterns in the vetter itself
echo
info "Checking vetter for unsafe patterns..."

UNSAFE_FOUND=0

# The vetter should not have real curl|sh patterns (only grep patterns)
if grep -rn "curl.*|.*sh\|wget.*|.*bash" "$PLUGIN_DIR/scripts/" 2>/dev/null | \
   grep -v "grep.*curl.*|.*sh\|grep.*wget.*|.*bash" | grep -v "^[^:]*:#" | grep . ; then
    info "Found curl|sh in vetter scripts (should only be in grep patterns)"
    UNSAFE_FOUND=1
fi

if [ $UNSAFE_FOUND -eq 0 ]; then
    pass "No unsafe patterns in vetter code"
else
    info "Manual review recommended for flagged patterns"
fi

echo
echo "=== All validations passed! ==="
echo "Plugin is ready for testing."
