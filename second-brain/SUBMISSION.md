# Marketplace Submission

Submission form answers for https://x.ai/bot/marketplace/submit-a-plugin

## Basic Information

### Plugin Name
```
second-brain
```

### Short Description (one sentence)
```
Orchestrator-agnostic shared memory for AI agents through a git-backed Obsidian vault that every agent reads at session start and safely writes back to.
```

### Long Description
```
Second Brain gives teams of AI agents persistent, shared memory through a plain-markdown vault synced via git. Unlike hosted memory solutions, your data lives in a git repository you control.

Works with Grok Bot, Cursor (IDE and cloud agents), Claude Desktop, Hermes, and other orchestrators. Humans can edit in Obsidian. Safe concurrent writes through explicit-path commits, per-agent folders, and rebase-with-retries.

Includes 7 skills: session-start (pull and read protocol), write-note (proper conventions), safe-sync (explicit paths only), capture-learning (self-improving pattern), link-check (find broken wikilinks), bootstrap-vault (setup from scratch), and maintenance (index/log upkeep).
```

### Category
```
Productivity
```

### Keywords
```
memory, obsidian, git, knowledge-management, multi-agent, markdown, vault, self-improving, shared-context, agent-memory, wikilinks, knowledge-graph
```

### License
```
MIT
```

### Repository URL
```
https://github.com/andreolf/grokbot-plugins
```

### Homepage URL
```
https://github.com/andreolf/grokbot-plugins/tree/main/second-brain
```

### Author Name
```
Francesco Andreoli
```

### Author Email
```
francesco@francescoswiss.com
```

### Plugin Path in Repository
```
second-brain
```

## Reviewer Testing Instructions

Complete testing workflow from a fresh account. Expected time: 10-15 minutes.

### Prerequisites
- Git installed and configured (`git config --global user.name "Test User"` and `user.email`)
- A GitHub account with a new private repository for testing

### Step 1: Install the Plugin

**In Grok Bot or Cursor:**
```
Install "Second Brain" from the plugin marketplace
```

Or manually for testing:
```bash
git clone https://github.com/andreolf/grokbot-plugins
cd grokbot-plugins/second-brain
```

### Step 2: Create a Test Vault Repository

**Create a bare remote:**
```bash
# On GitHub, create a new private repository: test-vault
# Or create a local bare repo for testing:
mkdir -p /tmp/test-vault-remote
cd /tmp/test-vault-remote
git init --bare
```

### Step 3: Bootstrap the Vault

**Set environment variable:**
```bash
export VAULT_PATH="/tmp/test-vault"
```

**In agent chat (Grok Bot/Cursor):**
```
Load the bootstrap-vault skill and create a new vault at /tmp/test-vault
```

**Expected outcome:**
- Vault created with folder structure: `Agents/`, `Notes/`, `Ideas/`, `Projects/`, `Inbox/`, `00-Core/`, etc.
- `AGENTS.md` protocol file present
- Templates created in `Templates/`
- Git initialized with initial commit
- Helper scripts in `scripts/`

**Verify:**
```bash
cd $VAULT_PATH
ls -la  # Should show folders and files
cat AGENTS.md  # Should show protocol
git log  # Should show "init: bootstrap test vault"
```

### Step 4: Add Remote and Push

```bash
cd $VAULT_PATH
git remote add origin /tmp/test-vault-remote  # or your GitHub repo URL
git push -u origin main
```

**Expected outcome:**
- Push succeeds
- Remote has the bootstrapped vault

### Step 5: Run First Agent Session

**In agent chat:**
```
Load vault-session-start skill. Read the vault protocol and create your agent folder in Agents/<your-agent-name>/
```

**Expected outcome:**
- Agent pulls vault (already up to date)
- Agent reads `AGENTS.md`
- Agent creates `Agents/<agent-name>/README.md`
- Agent creates subfolders: `outputs/`, `assets/`, `data/`

**Verify:**
```bash
ls $VAULT_PATH/Agents/
# Should show agent's folder
cat $VAULT_PATH/Agents/<agent-name>/README.md
# Should show role and learnings log section
```

### Step 6: Write and Sync

**In agent chat:**
```
Create a test output file in your outputs folder, then use safe-sync to commit and push.
```

**Expected outcome:**
- Agent creates `Agents/<agent-name>/outputs/YYYY-MM-DD-test-output.md`
- File has proper frontmatter (type, agent, created, tags)
- Agent commits with message like `<agent-name>: add test output`
- Agent successfully pushes to remote

**Verify:**
```bash
cd $VAULT_PATH
git log --oneline -3
# Should show agent's commit
git show HEAD
# Should show ONLY the agent's files (not everything)
```

### Step 7: Simulate Concurrent Agents

**Clone a second working copy (simulates another agent):**
```bash
cd /tmp
git clone /tmp/test-vault-remote test-vault-agent2
cd test-vault-agent2
git config user.name "Agent Two"
git config user.email "agent2@test.com"

# Create another agent folder
mkdir -p Agents/agent-two/outputs
cat > Agents/agent-two/outputs/$(date +%Y-%m-%d)-output.md << 'EOF'
---
type: agent-output
agent: agent-two
created: $(date +%Y-%m-%d)
---

# Agent Two Output

Test from second agent.
EOF

# Commit and push
git add Agents/agent-two/
git commit -m "agent-two: add output"
git push
```

**Back in first vault, create a file and try to push:**
```bash
cd $VAULT_PATH

# Create another file
cat > Agents/<agent-name>/outputs/$(date +%Y-%m-%d)-second-output.md << 'EOF'
---
type: agent-output
agent: <agent-name>
created: $(date +%Y-%m-%d)
---

# Second Output

Another test.
EOF

# Use sync script
./scripts/vault-sync.sh "<agent-name>: add second output" \
  Agents/<agent-name>/outputs/$(date +%Y-%m-%d)-second-output.md
```

**Expected outcome:**
- First push fails (remote has new commits)
- Script automatically pulls with rebase
- Rebase succeeds (different folders, no conflict)
- Push succeeds
- Both agents' changes are in the history

**Verify:**
```bash
git log --oneline -5
# Should show both agent commits
ls Agents/
# Should show both agent-name and agent-two folders
```

### Step 8: Verify Explicit Path Staging

**Create an untracked file in a different agent's folder:**
```bash
echo "Should not be staged" > Agents/agent-two/untracked.txt
```

**Commit your own file:**
```bash
echo "Another line" >> Agents/<agent-name>/README.md
git add -- Agents/<agent-name>/README.md
git commit -m "<agent-name>: update README"
```

**Verify untracked file was NOT staged:**
```bash
git status
# Should show Agents/agent-two/untracked.txt as untracked
git log -1 --name-only
# Should show ONLY Agents/<agent-name>/README.md
```

**Expected outcome:**
- Only the explicitly added file is committed
- Untracked files in other folders are NOT staged
- This proves `git add -A` is not used

### Step 9: Test Link Check

**In agent chat:**
```
Load link-check skill and check for broken wikilinks in the vault.
```

**Create a note with a broken link to test:**
```bash
cat > $VAULT_PATH/Notes/test-note.md << 'EOF'
---
type: note
created: $(date +%Y-%m-%d)
tags: [test]
---

# Test Note

This links to [[nonexistent-note]] which doesn't exist.
This links to [[AGENTS]] which does exist.
EOF
```

**Run link check:**
```bash
cd $VAULT_PATH
grep -roh '\[\[.*\]\]' --include="*.md" . | \
  sed 's/\[\[\([^|\]]*\).*/\1/' | sort | uniq > /tmp/links.txt

find . -name "*.md" | sed 's|^\./||; s|\.md$||' | sort > /tmp/files.txt

comm -23 /tmp/links.txt /tmp/files.txt
# Should show: nonexistent-note
```

**Expected outcome:**
- Link check detects `[[nonexistent-note]]` as broken
- Link check confirms `[[AGENTS]]` exists

### Step 10: Validation

**Run validation script:**
```bash
cd /path/to/grokbot-plugins/second-brain
./tests/validate-plugin.sh
```

**Expected output:**
```
✓ plugin.json exists
✓ plugin.json is valid JSON
✓ plugin.json has required 'name' field
✓ name 'second-brain' matches kebab-case pattern
✓ author.name present
✓ All plugin.json fields are allowed by schema
✓ Skills directory exists: skills
✓ All 7 skills validated
✓ README.md exists
✓ LICENSE exists
✓ CHANGELOG.md exists

=== All validations passed! ===
```

### Cleanup

```bash
# Remove test vault and remote
rm -rf /tmp/test-vault /tmp/test-vault-agent2 /tmp/test-vault-remote
unset VAULT_PATH
```

## Tests Run

- [x] Plugin installation
- [x] Vault bootstrap (folder structure, protocol, templates, git init)
- [x] First agent session (pull, read protocol, create agent folder)
- [x] Write note with proper frontmatter
- [x] Safe sync (explicit paths, commit, push)
- [x] Concurrent agents (two agents pushing, rebase handling)
- [x] Explicit path staging verification (untracked files NOT staged)
- [x] Link check (broken wikilinks detected)
- [x] Schema validation (plugin.json against official schema)
- [x] Frontmatter validation (all 7 skills have required fields)

## Security Review Notes

The plugin follows all Cursor/Grok Bot marketplace security guidelines:

1. **No `curl | bash`**: All scripts are committed and reviewable
2. **No secret reads**: Plugin never accesses credentials or environment secrets
3. **No obfuscation**: All code is plain bash and markdown
4. **No prompt injection**: Skills contain only instructions, no dynamic prompts
5. **Scoped operations**: Scripts operate only on `$VAULT_PATH`, never outside it
6. **Standard tools only**: Uses only git commands (`pull`, `push`, `commit`, `add`, `rebase`)
7. **No network calls**: Except git push/pull to user's own repository
8. **No file deletion**: Archives instead of deletes, preserving history

## Known Limitations

- Requires git installed and configured
- Not real-time (changes propagate on pull/push cycles)
- Merge conflicts possible if multiple agents edit same file
- No built-in access control (all agents can read all vault files)
- Network dependency for push/pull operations

## Support

- Issues: https://github.com/andreolf/grokbot-plugins/issues
- Documentation: https://github.com/andreolf/grokbot-plugins/tree/main/second-brain
- Author: francesco@francescoswiss.com
