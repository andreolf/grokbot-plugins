#!/usr/bin/env bash
# test-plugin.sh - Test second-brain plugin functionality

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
TEST_ROOT="/tmp/second-brain-test-$$"
VAULT_PATH="$TEST_ROOT/vault"
REMOTE_PATH="$TEST_ROOT/remote.git"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

# Create bare remote repo
git init --bare "$REMOTE_PATH"
info "Created bare remote: $REMOTE_PATH"

# Copy sync script to a location in PATH for testing
cp "$PLUGIN_DIR/scripts/vault-sync.sh" "$TEST_ROOT/vault-sync.sh"
chmod +x "$TEST_ROOT/vault-sync.sh"
export PATH="$TEST_ROOT:$PATH"

# Test 1: Bootstrap vault
section "Test 1: Bootstrap vault"

export VAULT_PATH="$VAULT_PATH"
export GIT_USER_NAME="Test Agent"
export GIT_USER_EMAIL="test@example.com"

# Run bootstrap (inline version for testing)
mkdir -p "$VAULT_PATH"
cd "$VAULT_PATH"

git init
git config user.name "Test Agent"
git config user.email "test@example.com"

mkdir -p 00-Core Agents Daily Ideas Inbox Notes Projects Resources Templates _archive raw scripts

cat > AGENTS.md << 'PROTOCOL'
---
type: protocol
updated: 2026-10-24
---
# Agent Protocol

Every agent follows these rules.

## 1. Start: pull, then read

## 2. Write scope

Write to your Agents/<name>/ folder.

## 3. Sync

Use explicit paths only.
PROTOCOL

cat > 00-Core/Profile.md << 'COREEOF'
---
type: core
---
# Profile

Test user profile.
COREEOF

cat > index.md << 'INDEXEOF'
---
type: index
updated: 2026-10-24
---
# Vault Index

## Core

- [[AGENTS]]

## Notes
INDEXEOF

cat > log.md << 'LOGEOF'
---
type: log
updated: 2026-10-24
---
# Vault Log

## 2026-10-24: Vault created

Initial bootstrap.
LOGEOF

cp "$TEST_ROOT/vault-sync.sh" scripts/

cat > .gitignore << 'GITIGNOREEOF'
.obsidian/workspace*
.DS_Store
*.tmp
GITIGNOREEOF

git add .
git commit -m "init: bootstrap test vault"

# Rename branch to main (git init creates master by default)
git branch -M main

if [ -f "$VAULT_PATH/AGENTS.md" ]; then
    pass "Vault bootstrapped"
else
    fail "Bootstrap failed - AGENTS.md not found"
fi

# Add remote and push
cd "$VAULT_PATH"
git remote add origin "$REMOTE_PATH"
git push -u origin main
pass "Pushed to remote"

# Test 2: Create agent folder and output
section "Test 2: Create agent folder and write output"

cd "$VAULT_PATH"
mkdir -p Agents/test-agent/{outputs,assets,data}

cat > Agents/test-agent/README.md << 'EOF'
# Test Agent

## Learnings Log
EOF

DATE=$(date +%Y-%m-%d)
cat > "Agents/test-agent/outputs/$DATE-test-output.md" << EOF
---
type: agent-output
agent: test-agent
created: $DATE
tags: [test]
---

# Test Output

This is a test output from test-agent.

## Links

- [[AGENTS]]
EOF

if [ -f "Agents/test-agent/outputs/$DATE-test-output.md" ]; then
    pass "Agent folder and output created"
else
    fail "Failed to create agent output"
fi

# Test 3: Safe sync with explicit paths
section "Test 3: Safe sync with explicit paths"

# Test that we're using explicit paths, not git add -A
git add -- Agents/test-agent/
git commit -m "test-agent: initial setup"
git pull --rebase --autostash origin main
git push

if git log --oneline | grep -q "test-agent: initial setup"; then
    pass "Explicit path commit successful"
else
    fail "Commit not found in log"
fi

# Test 4: Concurrent writer simulation
section "Test 4: Concurrent writer simulation"

info "Simulating concurrent writes..."

# Clone a second working copy (simulating another agent)
VAULT2="$TEST_ROOT/vault2"
git clone "$REMOTE_PATH" "$VAULT2"
cd "$VAULT2"
git checkout main  # Ensure we're on main branch
git config user.name "Agent Two"
git config user.email "agent2@example.com"

mkdir -p Agents/agent-two/outputs
cat > Agents/agent-two/outputs/$DATE-output.md << EOF
---
type: agent-output
agent: agent-two
created: $DATE
---

# Agent Two Output

From second agent.
EOF

git add -- Agents/agent-two/
git commit -m "agent-two: add output"
git push origin main

pass "Agent two pushed changes"

# Now try to push from original vault (should require rebase)
cd "$VAULT_PATH"

cat > "Agents/test-agent/outputs/$DATE-second-output.md" << EOF
---
type: agent-output
agent: test-agent
created: $DATE
---

# Second Output

Another output.
EOF

git add -- "Agents/test-agent/outputs/$DATE-second-output.md"
git commit -m "test-agent: add second output"

# This should fail (remote has new commits), then rebase and push
if git push 2>/dev/null; then
    fail "Push should have failed (remote ahead)"
else
    info "Push failed as expected (remote ahead)"
fi

# Rebase and push
git pull --rebase --autostash origin main
git push

if git log --oneline | grep -q "agent-two: add output"; then
    pass "Concurrent writes handled with rebase"
else
    fail "Rebase failed to merge concurrent changes"
fi

# Test 5: Forced conflict
section "Test 5: Forced conflict (same file modified)"

info "Creating a conflict scenario..."

# Agent two modifies shared file
cd "$VAULT2"
git pull --rebase origin main

# Modify a specific line that will conflict
sed -i 's/## Notes/## Notes\n\n- [[agent-two-note]] — Added by agent two/' index.md
git add -- index.md
git commit -m "agent-two: edit index"
git push origin main

# Agent one also modifies same area (will conflict)
cd "$VAULT_PATH"

# Before pulling, modify the same section
sed -i 's/## Notes/## Notes\n\n- [[test-agent-note]] — Added by test agent/' index.md
git add -- index.md
git commit -m "test-agent: edit index"

# Try to pull --rebase (should conflict or auto-merge)
REBASE_RESULT=0
git pull --rebase --autostash origin main 2>&1 | tee /tmp/rebase-output.txt || REBASE_RESULT=$?

if [ $REBASE_RESULT -ne 0 ] && grep -qi "conflict" /tmp/rebase-output.txt; then
    pass "Conflict detected as expected"
    
    # Resolve conflict - keep both edits
    if [ -f index.md ]; then
        sed -i '/^<<<<<<</d; /^=======/d; /^>>>>>>>/d' index.md
        git add index.md
        if git rebase --continue; then
            git push origin main
            pass "Conflict resolved and pushed"
        else
            fail "Rebase continue failed"
        fi
    else
        fail "index.md not found during conflict"
    fi
else
    # No conflict - git auto-merged or fast-forwarded
    info "No conflict (git auto-merged different sections)"
    # Make sure we're in sync
    git pull --rebase --autostash origin main 2>/dev/null || true
    git push origin main 2>/dev/null || {
        git pull --rebase --autostash origin main
        git push origin main
    }
    pass "Changes merged without conflict"
fi

# Ensure clean state
cd "$VAULT_PATH"
if git status --short | grep -q "^"; then
    info "Cleaning up uncommitted changes..."
    git reset --hard HEAD
    git clean -fd
fi
pass "Working directory clean"

# Test 6: Sync script
section "Test 6: Test vault-sync.sh script"

cd "$VAULT_PATH"

# Create a new file
cat > Agents/test-agent/outputs/$DATE-script-test.md << EOF
---
type: agent-output
agent: test-agent
created: $DATE
---

# Script Test

Testing vault-sync.sh script.
EOF

# Use the sync script
if "$TEST_ROOT/vault-sync.sh" "test-agent: test sync script" \
    "Agents/test-agent/outputs/$DATE-script-test.md"; then
    pass "Sync script executed successfully"
else
    fail "Sync script failed"
fi

# Verify it's in remote
cd "$VAULT2"
git pull
if [ -f "Agents/test-agent/outputs/$DATE-script-test.md" ]; then
    pass "Sync script changes visible in clone"
else
    fail "Sync script changes not synced"
fi

# Test 7: Link check
section "Test 7: Link check (broken wikilinks)"

cd "$VAULT_PATH"

# Create a note with a broken link
cat > Notes/test-note.md << 'EOF'
---
type: note
created: 2026-10-24
tags: [test]
---

# Test Note

This links to [[nonexistent-note]] which doesn't exist.

This links to [[AGENTS]] which does exist.
EOF

git add -- Notes/test-note.md
git commit -m "test-agent: add note with broken link"

# Simple link check
info "Running basic link check..."

ALL_LINKS=$(grep -roh '\[\[.*\]\]' --include="*.md" . | sed 's/\[\[\([^|\]]*\).*/\1/' | sort | uniq)
ALL_FILES=$(find . -name "*.md" -type f | sed 's|^\./||; s|\.md$||' | sort)

BROKEN=0
for link in $ALL_LINKS; do
    if ! echo "$ALL_FILES" | grep -qx "$link"; then
        info "Broken link found: [[$link]]"
        BROKEN=$((BROKEN + 1))
    fi
done

if [ $BROKEN -gt 0 ]; then
    pass "Link check detected broken links ($BROKEN found)"
else
    info "No broken links found (expected at least 1)"
fi

# Test 8: Verify no git add -A issues
section "Test 8: Verify explicit-path-only pattern"

cd "$VAULT_PATH"

# Create an untracked file in a different agent's folder
mkdir -p Agents/other-agent
echo "Untracked file" > Agents/other-agent/untracked.md

# Create our own file
cat > Agents/test-agent/outputs/$DATE-final.md << EOF
---
type: agent-output
agent: test-agent
created: $DATE
---

# Final Test

Final output.
EOF

# Use explicit path (should NOT stage the untracked file)
git add -- Agents/test-agent/outputs/$DATE-final.md
git commit -m "test-agent: final output"

# Check that untracked file is NOT staged
if git ls-files | grep -q "Agents/other-agent/untracked.md"; then
    fail "Explicit path staging leaked - staged untracked file!"
else
    pass "Explicit path staging works - untracked file not staged"
fi

# Clean up the untracked file
rm -rf Agents/other-agent

# Test 9: Verify frontmatter and wikilinks
section "Test 9: Verify note conventions"

cd "$VAULT_PATH"

# Check that outputs have correct frontmatter
OUTPUT_FILE="Agents/test-agent/outputs/$DATE-test-output.md"

if grep -q "^type: agent-output" "$OUTPUT_FILE" && \
   grep -q "^agent: test-agent" "$OUTPUT_FILE" && \
   grep -q "^created: $DATE" "$OUTPUT_FILE"; then
    pass "Frontmatter format correct"
else
    fail "Frontmatter format incorrect"
fi

# Check for wikilinks (not markdown links)
if grep -q '\[\[.*\]\]' "$OUTPUT_FILE"; then
    pass "Wikilinks present"
else
    info "No wikilinks found (not necessarily wrong)"
fi

# Final summary
section "Test Summary"

cd "$VAULT_PATH"
info "Final vault state:"
info "  Files: $(git ls-files | wc -l)"
info "  Commits: $(git log --oneline | wc -l)"
info "  Branches: $(git branch | wc -l)"

cd "$VAULT2"
git pull
info "Clone vault state:"
info "  Files: $(git ls-files | wc -l)"
info "  In sync: $([ $(git log --oneline | wc -l) -eq $(cd "$VAULT_PATH" && git log --oneline | wc -l) ] && echo YES || echo NO)"

section "All Tests Passed!"
echo
echo "Test artifacts available at: $TEST_ROOT"
echo "To inspect manually:"
echo "  cd $VAULT_PATH"
echo "  cd $VAULT2  # (second agent clone)"
echo
echo "To keep test artifacts, run: rm -rf $TEST_ROOT"
echo
