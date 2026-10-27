#!/usr/bin/env bash
# test-plugin.sh - Functional tests for skill-vetter

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
VET_SCRIPT="$PLUGIN_DIR/scripts/vet.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

pass() {
    echo -e "${GREEN}✓ $1${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail() {
    echo -e "${RED}✗ $1${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Test helper: run vetter and check exit code
test_vet() {
    local skill_path="$1"
    local expected_exit="$2"
    local test_name="$3"
    
    set +e
    "$VET_SCRIPT" "$skill_path" > /dev/null 2>&1
    local actual_exit=$?
    set -e
    
    if [ $actual_exit -eq $expected_exit ]; then
        pass "$test_name (exit $actual_exit)"
    else
        fail "$test_name (expected exit $expected_exit, got $actual_exit)"
    fi
}

echo "=== Testing Skill Vetter Plugin ==="
echo "Plugin directory: $PLUGIN_DIR"
echo "Vet script: $VET_SCRIPT"
echo

# Verify vet.sh exists
if [ ! -x "$VET_SCRIPT" ]; then
    fail "vet.sh not found or not executable"
    exit 1
fi

# Test 1: Good fixtures should pass (exit 0)
info "Testing good fixtures (should PASS)..."
for skill_dir in "$PLUGIN_DIR/tests/fixtures/good"/*/; do
    if [ ! -d "$skill_dir" ]; then
        continue
    fi
    skill_name=$(basename "$skill_dir")
    test_vet "$skill_dir" 0 "Good: $skill_name"
done
echo

# Test 2: Bad fixtures should fail or warn (exit 1 or 2)
info "Testing bad fixtures (should FAIL or WARN)..."

# Data exfiltration should fail (exit 2)
if [ -d "$PLUGIN_DIR/tests/fixtures/bad/data-exfiltration" ]; then
    set +e
    "$VET_SCRIPT" "$PLUGIN_DIR/tests/fixtures/bad/data-exfiltration" > /dev/null 2>&1
    exit_code=$?
    set -e
    if [ $exit_code -ge 1 ]; then
        pass "Bad: data-exfiltration detected (exit $exit_code)"
    else
        fail "Bad: data-exfiltration not detected"
    fi
fi

# Credential stealer should fail (exit 2)
if [ -d "$PLUGIN_DIR/tests/fixtures/bad/credential-stealer" ]; then
    set +e
    "$VET_SCRIPT" "$PLUGIN_DIR/tests/fixtures/bad/credential-stealer" > /dev/null 2>&1
    exit_code=$?
    set -e
    if [ $exit_code -eq 2 ]; then
        pass "Bad: credential-stealer detected (exit $exit_code)"
    else
        fail "Bad: credential-stealer not detected"
    fi
fi

# Remote execution should fail (exit 2)
if [ -d "$PLUGIN_DIR/tests/fixtures/bad/remote-execution" ]; then
    set +e
    "$VET_SCRIPT" "$PLUGIN_DIR/tests/fixtures/bad/remote-execution" > /dev/null 2>&1
    exit_code=$?
    set -e
    if [ $exit_code -eq 2 ]; then
        pass "Bad: remote-execution detected (exit $exit_code)"
    else
        fail "Bad: remote-execution not detected"
    fi
fi

# Hidden instructions should warn or fail (exit 1 or 2)
if [ -d "$PLUGIN_DIR/tests/fixtures/bad/hidden-instructions" ]; then
    set +e
    "$VET_SCRIPT" "$PLUGIN_DIR/tests/fixtures/bad/hidden-instructions" > /dev/null 2>&1
    exit_code=$?
    set -e
    if [ $exit_code -ge 1 ]; then
        pass "Bad: hidden-instructions detected (exit $exit_code)"
    else
        fail "Bad: hidden-instructions not detected"
    fi
fi

# Sudo escalation should fail (exit 2)
if [ -d "$PLUGIN_DIR/tests/fixtures/bad/sudo-escalation" ]; then
    set +e
    "$VET_SCRIPT" "$PLUGIN_DIR/tests/fixtures/bad/sudo-escalation" > /dev/null 2>&1
    exit_code=$?
    set -e
    if [ $exit_code -eq 2 ]; then
        pass "Bad: sudo-escalation detected (exit $exit_code)"
    else
        fail "Bad: sudo-escalation not detected"
    fi
fi

# Browser cookies should fail (exit 2)
if [ -d "$PLUGIN_DIR/tests/fixtures/bad/browser-cookies" ]; then
    set +e
    "$VET_SCRIPT" "$PLUGIN_DIR/tests/fixtures/bad/browser-cookies" > /dev/null 2>&1
    exit_code=$?
    set -e
    if [ $exit_code -eq 2 ]; then
        pass "Bad: browser-cookies detected (exit $exit_code)"
    else
        fail "Bad: browser-cookies not detected"
    fi
fi

echo

# Test 3: Plugin mode works
info "Testing plugin mode..."
# Create a minimal test plugin
TEST_PLUGIN_DIR="/tmp/test-plugin-$$"
mkdir -p "$TEST_PLUGIN_DIR/.cursor-plugin"
mkdir -p "$TEST_PLUGIN_DIR/skills/test-skill"

cat > "$TEST_PLUGIN_DIR/.cursor-plugin/plugin.json" << 'EOF'
{
  "name": "test-plugin",
  "author": {"name": "Test"}
}
EOF

cat > "$TEST_PLUGIN_DIR/skills/test-skill/SKILL.md" << 'EOF'
---
name: test-skill
description: A test skill
---
# Test
Safe content only.
EOF

set +e
"$VET_SCRIPT" --plugin "$TEST_PLUGIN_DIR" > /dev/null 2>&1
exit_code=$?
set -e

rm -rf "$TEST_PLUGIN_DIR"

if [ $exit_code -eq 0 ]; then
    pass "Plugin mode works (exit $exit_code)"
else
    fail "Plugin mode failed (exit $exit_code)"
fi

echo

# Summary
echo "=== Test Summary ==="
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"
echo

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
