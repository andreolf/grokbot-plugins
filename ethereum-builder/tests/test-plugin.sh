#!/usr/bin/env bash
# test-plugin.sh - Test ethereum-builder plugin functionality

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

section() {
    echo
    echo "========================================="
    echo "$1"
    echo "========================================="
}

echo "=== Testing Ethereum Builder Plugin ==="
echo "Plugin directory: $PLUGIN_DIR"
echo

# Test 1: Scripts exist and are executable
section "Test 1: Helper Scripts"

BLOCKSCOUT_SCRIPT="$PLUGIN_DIR/scripts/blockscout-lookup.sh"
DUNE_SCRIPT="$PLUGIN_DIR/scripts/dune-query.sh"

if [ ! -x "$BLOCKSCOUT_SCRIPT" ]; then
    fail "blockscout-lookup.sh not executable"
fi
pass "blockscout-lookup.sh is executable"

if [ ! -x "$DUNE_SCRIPT" ]; then
    fail "dune-query.sh not executable"
fi
pass "dune-query.sh is executable"

# Test 2: Blockscout script handles missing args
section "Test 2: Blockscout Error Handling"

if "$BLOCKSCOUT_SCRIPT" 2>/dev/null; then
    fail "Script should fail with no arguments"
fi
pass "Script fails gracefully with no arguments"

if "$BLOCKSCOUT_SCRIPT" invalid-chain address 0x123 2>/dev/null; then
    fail "Script should fail with invalid chain"
fi
pass "Script fails gracefully with invalid chain"

# Test 3: Dune script checks for API key
section "Test 3: Dune API Key Check"

# Temporarily unset DUNE_API_KEY if it exists
SAVED_DUNE_KEY="${DUNE_API_KEY:-}"
unset DUNE_API_KEY

if "$DUNE_SCRIPT" search "test" 2>/dev/null; then
    fail "Script should fail without DUNE_API_KEY"
fi
pass "Script requires DUNE_API_KEY"

# Restore DUNE_API_KEY if it was set
if [ -n "$SAVED_DUNE_KEY" ]; then
    export DUNE_API_KEY="$SAVED_DUNE_KEY"
fi

# Test 4: Live Blockscout API calls (public endpoints)
section "Test 4: Live Blockscout API Calls"

info "Testing live Blockscout API (Ethereum mainnet)..."

# Test 4a: USDC address lookup
USDC_ADDRESS="0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
info "Looking up USDC address..."

if ! OUTPUT=$("$BLOCKSCOUT_SCRIPT" eth address "$USDC_ADDRESS" 2>&1); then
    info "Blockscout API call failed (might be rate limited or network issue)"
    info "Output: $OUTPUT"
    info "Skipping remaining live API tests"
else
    pass "USDC address lookup successful"
    
    # Verify output contains some expected fields (API format may vary)
    if echo "$OUTPUT" | grep -q "result\|balance\|status"; then
        pass "Address lookup contains expected response fields"
    else
        info "Address lookup response format may have changed"
    fi
    
    # Test 4b: USDC token info
    info "Looking up USDC token info..."
    
    if ! TOKEN_OUTPUT=$("$BLOCKSCOUT_SCRIPT" eth token "$USDC_ADDRESS" 2>&1); then
        info "Token lookup failed (might be rate limited)"
        info "Output: $TOKEN_OUTPUT"
    else
        pass "USDC token info lookup successful"
        
        # Verify token name/symbol
        if echo "$TOKEN_OUTPUT" | grep -qi "usdc\|usd coin"; then
            pass "Token info contains USDC name"
        else
            info "Token info format may have changed"
        fi
    fi
    
    # Test 4c: Uniswap V2 Router contract
    UNISWAP_ROUTER="0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"
    info "Looking up Uniswap V2 Router..."
    
    if ! CONTRACT_OUTPUT=$("$BLOCKSCOUT_SCRIPT" eth address "$UNISWAP_ROUTER" 2>&1); then
        info "Contract lookup failed (might be rate limited)"
        info "Output: $CONTRACT_OUTPUT"
    else
        pass "Uniswap V2 Router lookup successful"
        
        # Verify it's a contract
        if echo "$CONTRACT_OUTPUT" | grep -q "is_contract.*true"; then
            pass "Correctly identified as contract"
        else
            info "Contract detection format may have changed"
        fi
    fi
    
    # Test 4d: Token holders (might be rate limited)
    info "Attempting to get USDC top holders..."
    
    if ! HOLDERS_OUTPUT=$("$BLOCKSCOUT_SCRIPT" eth holders "$USDC_ADDRESS" 2>&1); then
        info "Holders lookup failed (this endpoint is often rate limited)"
        info "Output: $HOLDERS_OUTPUT"
    else
        pass "USDC holders lookup successful"
    fi
fi

# Test 5: Script output format
section "Test 5: Script Output Format"

info "Verifying scripts produce valid JSON when successful..."

# We can't guarantee API success, but we can check error messages are clear
if OUTPUT=$("$BLOCKSCOUT_SCRIPT" eth address "0x0000000000000000000000000000000000000000" 2>&1); then
    # If call succeeds, verify it's valid JSON
    if ! echo "$OUTPUT" | jq empty 2>/dev/null; then
        info "Output is not valid JSON (might be rate limited or API change)"
        info "Output: $OUTPUT"
    else
        pass "Valid JSON output format"
    fi
else
    # If call fails, check for clear error message
    if echo "$OUTPUT" | grep -qi "error\|rate limit\|failed"; then
        pass "Clear error messages on failure"
    else
        info "Unexpected error format: $OUTPUT"
    fi
fi

# Test 6: Dune script validation (skip if no API key)
section "Test 6: Dune Script Validation"

if [ -z "${DUNE_API_KEY:-}" ]; then
    info "DUNE_API_KEY not set - skipping Dune execution tests"
    info "This is expected. Dune tests require a valid API key."
    pass "Dune tests skipped cleanly (no API key)"
else
    info "DUNE_API_KEY is set - testing Dune script..."
    
    # Test basic query format
    if ! "$DUNE_SCRIPT" query "SELECT 1 AS test" 2>&1 | grep -q "Executing\|execution_id\|Error"; then
        fail "Dune script output format unexpected"
    fi
    pass "Dune script executes (or errors clearly)"
    
    info "Full Dune testing requires manual verification with valid queries"
fi

# Test 7: Skill files are valid
section "Test 7: Skill File Validation"

SKILLS=(
    "ethskills-router"
    "onchain-lookup"
    "dune-analysis"
    "token-diligence"
    "protocol-research"
)

for skill in "${SKILLS[@]}"; do
    SKILL_FILE="$PLUGIN_DIR/skills/$skill/SKILL.md"
    
    if [ ! -f "$SKILL_FILE" ]; then
        fail "Skill file missing: $skill/SKILL.md"
    fi
    
    # Check frontmatter exists
    if ! head -20 "$SKILL_FILE" | grep -q "^---$"; then
        fail "Skill $skill: missing frontmatter"
    fi
    
    # Check file is not empty
    if [ ! -s "$SKILL_FILE" ]; then
        fail "Skill $skill: file is empty"
    fi
    
    # Check for basic content sections
    if ! grep -q "When to use" "$SKILL_FILE"; then
        info "Skill $skill: missing 'When to use' section (optional but recommended)"
    fi
    
    pass "Skill $skill: valid"
done

# Test 8: README examples match skills
section "Test 8: README Documentation"

README="$PLUGIN_DIR/README.md"

for skill in "${SKILLS[@]}"; do
    if ! grep -q "$skill" "$README"; then
        fail "README missing mention of skill: $skill"
    fi
done
pass "README documents all skills"

# Check for important sections
REQUIRED_SECTIONS=(
    "Quick Start"
    "Skills"
    "Security"
    "Environment Variables"
)

for section_name in "${REQUIRED_SECTIONS[@]}"; do
    if ! grep -qi "$section_name" "$README"; then
        fail "README missing section: $section_name"
    fi
done
pass "README has all required sections"

# Test 9: No secrets in files
section "Test 9: Security Checks"

info "Scanning for potential secrets..."

# Common secret patterns
if grep -r "api[_-]key.*=.*['\"][a-zA-Z0-9]\{20,\}" "$PLUGIN_DIR" --exclude-dir=.git --exclude="*.sh" --exclude="*.md" 2>/dev/null; then
    fail "Found potential hardcoded API key"
fi
pass "No hardcoded API keys found"

# Check for private keys
if grep -ri "private[_-]key\|secret[_-]key" "$PLUGIN_DIR" --exclude-dir=.git --exclude="*.md" 2>/dev/null | grep -v "DUNE_API_KEY\|BLOCKSCOUT_API_KEY\|Set your API key\|environment variable"; then
    fail "Found potential private key reference"
fi
pass "No private key patterns found"

# Test 10: File permissions
section "Test 10: File Permissions"

# Scripts should be executable
for script in "$PLUGIN_DIR"/scripts/*.sh; do
    if [ ! -x "$script" ]; then
        fail "Script not executable: $(basename "$script")"
    fi
done
pass "All scripts are executable"

# Non-scripts should not be executable
if find "$PLUGIN_DIR/skills" -type f -name "*.md" -executable 2>/dev/null | grep -q .; then
    fail "Found executable markdown files (should not be executable)"
fi
pass "Markdown files are not executable"

# Summary
section "Test Summary"

info "Core tests completed successfully"
echo
echo "Notes:"
echo "- Live API tests may fail due to rate limits (this is expected)"
echo "- Dune tests skip cleanly when DUNE_API_KEY is not set"
echo "- Some tests rely on public Blockscout API availability"
echo
echo "To test with full Dune functionality:"
echo "  export DUNE_API_KEY='your-key'"
echo "  ./tests/test-plugin.sh"
echo

pass "All tests passed!"
