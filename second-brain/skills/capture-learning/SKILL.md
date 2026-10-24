---
name: capture-learning
description: Capture learnings, errors, corrections, and decisions back to the vault at the end of a task. Implements the self-improving agent pattern by recording what worked, what failed, and what to do differently next time.
---

# Capture Learning

Record learnings, decisions, and task outcomes back to the vault at the end of work. This implements the self-improving agent pattern: agents learn from experience by writing down what worked and what didn't.

## When to capture learnings

Capture at the end of:

1. **Completed tasks** — What you built, how it went, what you'd do differently
2. **Error resolution** — What failed, root cause, the fix
3. **Significant decisions** — Why you chose approach A over B
4. **Pattern discovery** — Found a better way to do something
5. **Dead ends** — Tried something that didn't work (save others the time)

Don't capture:
- Trivial tasks (fixed a typo, answered a question)
- Work in progress (wait until done or blocked)
- Duplicates (if you already logged it)

## What to capture

### For completed tasks

```markdown
## YYYY-MM-DD: <task description>

**Context:** What you were asked to do.

**Approach:** How you did it.

**Outcome:** What resulted. Link to outputs: [[YYYY-MM-DD-output-file]]

**Learnings:**
- What worked well
- What was difficult
- What to do differently next time
```

### For errors and fixes

```markdown
## YYYY-MM-DD: <error description>

**Error:** What failed.

**Root cause:** Why it failed.

**Fix:** How you resolved it.

**Prevention:** How to avoid this next time.
```

### For decisions

```markdown
## YYYY-MM-DD: <decision>

**Context:** The situation.

**Options considered:**
1. Option A — pros/cons
2. Option B — pros/cons

**Decision:** Chose option A.

**Reasoning:** Why A over B.
```

## Where to write learnings

### Your agent README

The primary location is your `Agents/<name>/README.md`. Structure it with newest entries at the top:

```markdown
# Agent Name

Role and purpose.

## Learnings Log

### 2026-10-24: Implemented vault sync with explicit paths

**Context:** Building second-brain plugin, needed safe multi-agent sync.

**Approach:** Script that stages only specified paths, rebases with retries.

**Outcome:** [[2026-10-24-second-brain-plugin]] created and tested.

**Learnings:**
- `git add -A` breaks concurrent writes; explicit paths required
- Rebase conflicts outside write scope → abort and propose via Inbox
- Verify files with `ls` before committing; tool outputs can lie

### 2026-10-23: First vault interaction

...
```

### Project logs

For project-specific work, also add an entry to the project's log:

```bash
# Append to project log (newest at top)
cat >> Projects/project-name/project-name-log.md << 'EOF'

## 2026-10-24: <your-agent-name>

Brief entry about what you did and learned on this project.

Link: [[Agents/your-agent-name/outputs/YYYY-MM-DD-output]]
EOF
```

### Shared knowledge base

For learnings that apply to all agents, create a note in `Notes/` or update an existing one:

```markdown
---
type: note
created: YYYY-MM-DD
tags: [git, multi-agent, sync]
---

# Safe Git Sync in Multi-Agent Environments

Key principle: Never `git add -A` when multiple agents write concurrently.

## Pattern

[...]

## Discovered by

[[Agents/your-agent-name/README]] — YYYY-MM-DD
```

## Self-improving agent pattern

This pattern comes from the OpenClaw community (ClawHub's self-improving-agent skill, 488k downloads). The cycle:

1. **Try** — Attempt the task
2. **Record** — Log what happened (success or failure)
3. **Learn** — Extract patterns from your log
4. **Apply** — Use those patterns on the next task

### Implementing the cycle

Your `README.md` is the learning store. At the start of each task:

1. **Read your README** (`vault-session-start` already does this)
2. **Scan your learnings log** for relevant patterns
3. **Apply those patterns** to the current task

At the end:

4. **Record the outcome** in your README
5. **Update patterns** if you learned something new

### Example of applying learnings

You logged previously:

```markdown
### 2026-10-20: vault sync failed - used git add -A

**Error:** Push succeeded but another agent's work disappeared.

**Root cause:** `git add -A` staged their uncommitted work under my name.

**Fix:** Revert, then use explicit paths.

**Prevention:** NEVER use `git add -A`. Always list paths explicitly.
```

Next task (2026-10-24), you read your README and see this entry. When syncing, you remember: use explicit paths only. You avoid the mistake.

## Format for different entry types

### Task completion

```markdown
### YYYY-MM-DD: <task-name>

Completed <task>. [[link-to-output]]

Key learnings:
- Learning 1
- Learning 2
```

### Error/failure

```markdown
### YYYY-MM-DD: ERROR - <short-description>

**What failed:** Description

**Root cause:** Why

**Fix:** How resolved

**Pattern:** Never do X; always do Y instead
```

### Discovery

```markdown
### YYYY-MM-DD: DISCOVERY - <finding>

Found that <discovery>.

Applies to: <context>

Use when: <situation>
```

### Decision

```markdown
### YYYY-MM-DD: DECISION - <what>

Chose <option> over <alternative>.

Reasoning: <why>

Trade-offs: <what we gave up>
```

## Linking between learnings and outputs

Always link your learnings to your concrete outputs:

```markdown
### 2026-10-24: Analyzed GitHub plugins

Completed plugin analysis. [[2026-10-24-github-plugin-analysis]]

Learnings:
- Most plugins bundle MCP connectors (412/482)
- Skills-only plugins are rare (70/482)
- Git-based memory: zero existing plugins (gap opportunity)
```

Someone reading your README can click through to the full output.

## Updating standing patterns

If you discover something that changes how you work, update a "Patterns" or "Rules" section in your README:

```markdown
## Patterns

### Git sync
- NEVER `git add -A` (breaks concurrent writes)
- ALWAYS use explicit paths
- Pull before commit, rebase before push

### Vault writing
- Read protocol first (AGENTS.md)
- Write only to your Agents/<name>/ unless explicitly allowed
- Verify files exist before committing

### Error handling
- Check `git status` and `ls`, never trust tool outputs alone
- If rebase conflicts outside your scope: abort and propose via Inbox
- Log every non-trivial error to prevent recurrence
```

Then in your learnings log, reference the pattern:

```markdown
### 2026-10-24: Applied git sync pattern

Used explicit path sync pattern (see § Patterns).

Worked perfectly with 3 concurrent agents writing.
```

## Capture learning workflow

```bash
#!/usr/bin/env bash
set -euo pipefail

VAULT_PATH="${VAULT_PATH:-/vault}"
AGENT_NAME="your-agent-name"
DATE=$(date +%Y-%m-%d)

cd "$VAULT_PATH"

# 1. Open your README for editing
README="Agents/$AGENT_NAME/README.md"

# 2. Add entry at the top of your learnings log section
# Use your text editor, or append like this:

cat >> "$README" << EOF

### $DATE: <task-description>

**Context:** What you were doing.

**Outcome:** What resulted. [[link-to-output]]

**Learnings:**
- Key learning 1
- Key learning 2

EOF

# 3. Commit just the README
git add -- "$README"
git commit -m "$AGENT_NAME: capture learnings from <task>"
git pull --rebase --autostash origin main
git push
```

Or use the sync script:

```bash
# Edit README, then:
vault-sync.sh "your-agent-name: capture learnings from <task>" \
  Agents/your-agent-name/README.md
```

## Integration with other skills

Capture learning complements:

- **`write-note`** — Creates your outputs; capture-learning links to them
- **`safe-sync`** — Commits your learning entries safely
- **`vault-session-start`** — Reads your learnings at the start of next session

The cycle:

1. Session start → read README learnings
2. Do task → create outputs (`write-note`)
3. End task → capture learnings (this skill)
4. Sync → commit safely (`safe-sync`)
5. Next session → read the new learnings → repeat

## Examples

### After successful plugin build

```markdown
### 2026-10-24: Built second-brain plugin

Created marketplace plugin for git-based vault memory. 
[[2026-10-24-second-brain-plugin]]

**Learnings:**
- Manifest needs primitives.skills array with paths
- SKILL.md frontmatter triggers: when agents should load the skill
- Sync script must handle concurrent writes with explicit paths only
- Test with throwaway repo + forced conflict to verify rebase handling

**Patterns established:**
- Bootstrap before writing (create vault structure first)
- Pull → read → write → verify → sync (never skip verification)
```

### After hitting an error

```markdown
### 2026-10-24: ERROR - Rebase conflict in 00-Core/Profile.md

**What failed:** Tried to update 00-Core/Profile.md directly; rebase conflicted.

**Root cause:** Another agent modified it while I worked. Also: I wasn't 
supposed to edit 00-Core directly (should propose via Inbox).

**Fix:** `git rebase --abort`, then created Inbox/2026-10-24-proposal.md instead.

**Pattern:** NEVER edit 00-Core directly unless explicitly asked. Proposals 
go through Inbox. On rebase conflicts outside my scope: abort immediately.
```

### After discovering a better approach

```markdown
### 2026-10-24: DISCOVERY - sync script handles retries

Found that the vault's sync script retries pull --rebase 3 times with delays.

**Why it matters:** Handles concurrent agent pushes automatically. I don't 
need to implement retry logic; just use the script.

**Pattern update:** Prefer `vault-sync.sh` over manual git commands. It 
handles concurrent writes better than I would.
```

## Checklist

At the end of a task:

- [ ] Task completed or blocked
- [ ] Have concrete outcome (success/failure/learning)
- [ ] Entry prepared (context, outcome, learnings)
- [ ] Entry added to `Agents/<name>/README.md` (newest first)
- [ ] If project work: entry also added to project log
- [ ] Learnings link to output files with `[[wikilinks]]`
- [ ] If pattern discovered: updated your Patterns section
- [ ] Committed with `vault-sync.sh` or explicit path sync
- [ ] Next session will read this learning and apply it
