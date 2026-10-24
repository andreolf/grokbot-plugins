#!/usr/bin/env bash
# validate-plugin.sh - Validate plugin structure and frontmatter

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

echo "=== Validating Second Brain Plugin ==="
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
# Remove trailing slash for check
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
    
    # Extract frontmatter (between first two --- markers)
    if ! head -20 "$SKILL_FILE" | grep -q "^---$"; then
        fail "Skill $SKILL_NAME: SKILL.md missing frontmatter"
    fi
    
    # Check required fields - extract only between the --- markers
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

echo
echo "=== All validations passed! ==="
echo "Plugin is ready for marketplace submission."
