---
name: safe-sync
description: Safely commit and push vault changes with explicit path staging, rebase-then-push, and conflict handling. NEVER use 'git add -A' or 'git add .' — always stage only the specific files you created or modified. Required after any vault write.
metadata:
  surfaces:
    - ide
    - cloud
  triggers:
    - after writing files
    - committing changes
    - pushing to remote
---

# Safe Sync

Commit and push vault changes safely in a multi-agent environment. **Critical:** Many agents write to this vault simultaneously, so you must stage ONLY your own files.

## The cardinal rule

**NEVER use `git add -A`, `git add .`, or stage everything.**

Multiple agents write to the vault concurrently. Staging everything sweeps up their half-finished work under your commit name, corrupting the history and breaking their changes.

## Using the sync script

The vault includes a helper script that implements safe sync:

```bash
VAULT_PATH="${VAULT_PATH:-/vault}"
cd "$VAULT_PATH"

# Usage: scripts/vault-sync.sh "<agent-name>: <message>" <path> [<path> ...]
./scripts/vault-sync.sh "research-bot: add github analysis" \
  Agents/research-bot/outputs/2026-10-24-github-analysis.md \
  Agents/research-bot/README.md
```

Or if the script is on your PATH:

```bash
vault-sync.sh "research-bot: add github analysis" \
  Agents/research-bot/ \
  Inbox/2026-10-24-research-bot-proposal.md
```

### What the script does

1. **Stages only the paths you list** — never everything
2. **Commits with your message** — if there are staged changes
3. **Pulls with rebase** — `git pull --rebase --autostash origin main`
4. **Retries 3 times** — if pull fails (handles concurrent agent pulls)
5. **Pushes to remote** — after successful rebase

## Manual sync (when script isn't available)

If you can't use the script, implement the same logic manually:

```bash
VAULT_PATH="${VAULT_PATH:-/vault}"
REMOTE="${VAULT_REMOTE:-origin}"
BRANCH="${VAULT_BRANCH:-main}"
AGENT_NAME="your-agent-name"

cd "$VAULT_PATH"

# 1. Stage ONLY your files (list them explicitly)
git add -- Agents/$AGENT_NAME/outputs/2026-10-24-output.md \
          Agents/$AGENT_NAME/README.md

# 2. Commit if there are changes
if ! git diff --cached --quiet; then
  git commit -m "$AGENT_NAME: descriptive message"
fi

# 3. Pull with rebase, retry up to 3 times
for i in 1 2 3; do
  if git pull --rebase --autostash "$REMOTE" "$BRANCH"; then
    break
  fi
  echo "Pull failed (attempt $i), retrying..." >&2
  sleep 5
  if [ $i = 3 ]; then
    echo "Pull --rebase failed after 3 attempts" >&2
    exit 1
  fi
done

# 4. Push
git push
```

## Commit message format

Always prefix with your agent name:

```
<agent-name>: <clear description>
```

Examples:
- `research-bot: add github plugin analysis`
- `coding-bot: process inbox captures`
- `claude-desktop: weekly synthesis for 2026-10-24`

## What to stage

### Stage your entire agent folder

If all your changes are in your own folder:

```bash
git add -- Agents/your-agent-name/
```

### Stage specific files

When you've also written to `Inbox/` or other locations:

```bash
git add -- Agents/your-agent-name/ \
          Inbox/2026-10-24-proposal.md \
          Projects/project-name/project-name.md
```

### NEVER stage everything

```bash
# WRONG - breaks other agents' work
git add -A
git add .
git add *

# RIGHT - explicit paths only
git add -- Agents/your-agent-name/ Inbox/specific-file.md
```

## Handling conflicts

### If pull --rebase fails repeatedly

After 3 retries, the script exits. This means:
1. Network issues, OR
2. Persistent conflicts

Check the git status:

```bash
git status
```

### Conflicts in files you own

If the conflict is in your own `Agents/<name>/` folder, you and another process modified the same file. Resolve manually:

```bash
# See conflicts
git status

# Edit the conflicted file(s) to resolve
# Remove conflict markers: <<<<<<< ======= >>>>>>>

# Mark as resolved
git add <conflicted-file>

# Continue rebase
git rebase --continue

# Push
git push
```

### Conflicts in files outside your scope

If conflicts are in files you shouldn't be touching (another agent's folder, `00-Core/` without permission, `raw/`):

**Abort the rebase:**

```bash
git rebase --abort
```

Then create a proposal in `Inbox/` instead:

```bash
cat > Inbox/$(date +%Y-%m-%d)-your-agent-name-proposed-change.md << 'EOF'
---
type: proposal
status: open
created: $(date +%Y-%m-%d)
agent: your-agent-name
---

# Proposal: <what you wanted to change>

## Motivation

Why this change?

## Conflict

Rebase conflict prevented direct edit. Proposing through Inbox instead.

## Proposed Change

What to change.
EOF

# Commit just the proposal
git add -- Inbox/$(date +%Y-%m-%d)-your-agent-name-proposed-change.md
git commit -m "your-agent-name: propose change to <file>"
git pull --rebase --autostash origin main
git push
```

## Concurrent writer scenario

**Situation:** Agent A and Agent B both pull, modify their own folders, and try to push simultaneously.

**What happens:**

1. Agent A pushes first → succeeds
2. Agent B tries to push → fails (remote has new commits)
3. Agent B's pull --rebase → succeeds (no conflicts, different folders)
4. Agent B pushes → succeeds

**If they modified the same file:**

1. Agent A pushes first → succeeds
2. Agent B tries to push → fails
3. Agent B's pull --rebase → **conflict**
4. Agent B resolves → continues rebase → pushes

This is why the script retries 3 times with delays: it handles the common case where another agent pushed microseconds before you.

## Verification before committing

**Always verify your changes before committing:**

```bash
# See what will be committed
git diff --cached

# See which files will be committed
git diff --cached --name-only

# Check for untracked files you created
git status

# List files in your working directory
ls -la Agents/your-agent-name/outputs/
```

Trust nothing about tool-reported write success. Check `git status` and `ls` before committing.

## Stray untracked files

From `AGENTS.md` § 2a: **Commit everything you create; never leave untracked files behind.**

If you create files and don't commit them, the nightly cleanup process may remove them, or another agent might commit them under their name.

Check for untracked files:

```bash
git status --porcelain | grep "^??"
```

If you see untracked files in your folder, add them:

```bash
git add -- Agents/your-agent-name/untracked-file.md
```

## Special case: "Cannot rebase onto multiple branches"

If `git pull --rebase` says **"Cannot rebase onto multiple branches"**, another agent is pulling at the exact same moment. 

The fix:

```bash
# Wait a few seconds
sleep 5

# Fetch and rebase explicitly
git fetch origin
git rebase origin/main
```

The script handles this with retries, so it should be rare.

## Complete workflow example

```bash
#!/usr/bin/env bash
set -euo pipefail

VAULT_PATH="${VAULT_PATH:-/vault}"
AGENT_NAME="research-bot"
DATE=$(date +%Y-%m-%d)

cd "$VAULT_PATH"

# 1. Pull first (vault-session-start)
git pull --rebase --autostash origin main

# 2. Create your work
mkdir -p "Agents/$AGENT_NAME/outputs"
cat > "Agents/$AGENT_NAME/outputs/$DATE-analysis.md" << 'EOF'
---
type: agent-output
agent: research-bot
created: 2026-10-24
---

# Analysis

Content here.
EOF

# 3. Update your README
echo "- [[$DATE-analysis]] — Analysis output" >> "Agents/$AGENT_NAME/README.md"

# 4. Verify files before committing
echo "Files to commit:"
ls -la "Agents/$AGENT_NAME/outputs/$DATE-analysis.md"
ls -la "Agents/$AGENT_NAME/README.md"

# 5. Use the sync script with explicit paths
./scripts/vault-sync.sh "$AGENT_NAME: add analysis output" \
  "Agents/$AGENT_NAME/outputs/$DATE-analysis.md" \
  "Agents/$AGENT_NAME/README.md"

# Or manually:
# git add -- "Agents/$AGENT_NAME/outputs/$DATE-analysis.md" \
#           "Agents/$AGENT_NAME/README.md"
# git commit -m "$AGENT_NAME: add analysis output"
# git pull --rebase --autostash origin main
# git push
```

## Checklist

Before syncing:

- [ ] Pulled latest changes (`vault-session-start`)
- [ ] Created/modified only files in your write scope
- [ ] Verified files exist with `ls` or `cat`
- [ ] Checked `git status` for untracked files
- [ ] Have explicit paths for EVERY file you're committing
- [ ] NOT using `git add -A`, `git add .`, or `git add *`

During sync:

- [ ] Using `vault-sync.sh` script with explicit paths, OR
- [ ] Manually: `git add -- <explicit paths>`
- [ ] Commit message starts with `<agent-name>:`
- [ ] Pull with rebase before push
- [ ] Handling conflicts appropriately (resolve your files, abort others)

After sync:

- [ ] Push succeeded
- [ ] No untracked files left in your folder
- [ ] Remote has your commit
