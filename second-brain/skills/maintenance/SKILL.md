---
name: maintenance
description: Maintain vault health by updating index.md and log.md when adding or modifying knowledge base notes. Use automatically after creating or substantially modifying notes in Notes/, Ideas/, or Projects/.
metadata:
  surfaces:
    - ide
    - cloud
  triggers:
    - after creating note
    - after modifying note
    - knowledge base update
    - processing inbox
---

# Maintenance

Keep `index.md` and `log.md` up to date when working with the knowledge base. This maintains discoverability and history.

## When maintenance is required

From `AGENTS.md` § 6: When you add or substantively modify a note in `Notes/`, `Ideas/`, or `Projects/`, also:

1. **Register it in `index.md`** under the right section
2. **Add a dated entry to `log.md`** (newest at top)

"Substantively modify" means:
- Adding new ideas or content (not just typos)
- Restructuring the note
- Adding major sections
- Merging notes

Skip maintenance for:
- Typo fixes
- Formatting tweaks
- Adding a single wikilink
- Your own `Agents/<name>/` folder (has its own README log)
- Files in `Inbox/`, `Daily/`, `raw/`, `Templates/`

## Updating index.md

### Structure

`index.md` is organized by section:

```markdown
---
type: index
updated: YYYY-MM-DD
---
# Vault Index

## Core

- [[AGENTS]]
- [[00-Core/Profile]]
- [[00-Core/Preferences]]
- [[00-Core/Active-Projects]]

## Notes

- [[note-one]] — Short description
- [[note-two]] — Short description

## Ideas

- [[idea-one]] — Hypothesis about X
- [[idea-two]] — Open question about Y

## Projects

- [[Projects/project-name/project-name]] — Project description

## Resources

- [[Resources/resource-name]] — Resource description

## Metadata conventions

(Controlled type, tag, and status lists)
```

### Adding a note to index

```bash
VAULT_PATH="${VAULT_PATH:-/vault}"
NOTE_NAME="new-note-name"
SECTION="Notes"  # or Ideas, Projects, Resources

# Add to the right section
# Find the section, insert after header
sed -i "/^## ${SECTION}\$/a- [[${NOTE_NAME}]] — Short description" \
  "$VAULT_PATH/index.md"

# Update the 'updated' date in frontmatter
DATE=$(date +%Y-%m-%d)
sed -i "s/^updated: .*/updated: $DATE/" "$VAULT_PATH/index.md"
```

Or manually:

```markdown
## Notes

- [[new-note-name]] — Brief one-line description
- [[existing-note]] — Description
```

### Organizing within sections

Keep alphabetical or by topic:

```markdown
## Notes

### Git & Version Control

- [[git-rebase-workflow]] — Rebase best practices
- [[multi-agent-git-sync]] — Concurrent writes in git

### Memory & Knowledge

- [[llm-wiki-pattern]] — Karpathy's LLM wiki pattern
- [[rag-vs-llm-wiki]] — RAG vs wiki approaches
```

## Updating log.md

### Structure

`log.md` is **append-only**, newest entries at top:

```markdown
---
type: log
updated: YYYY-MM-DD
---
# Vault Log

Newest entries at top. Never edit past entries.

## YYYY-MM-DD: <change-description>

Details. Link to [[affected-note]].

## YYYY-MM-DD: <another-change>

Details.
```

### Adding a log entry

```bash
VAULT_PATH="${VAULT_PATH:-/vault}"
DATE=$(date +%Y-%m-%d)
AGENT_NAME="your-agent-name"

# Prepend new entry after frontmatter
cat > /tmp/log-entry.txt << EOF

## $DATE: Added new note on git sync patterns

Created [[multi-agent-git-sync]] covering explicit-path staging and rebase patterns.

Added by: [[Agents/$AGENT_NAME/README]]

EOF

# Insert after frontmatter (after line 5 or first "# Vault Log")
sed -i '/^# Vault Log$/r /tmp/log-entry.txt' "$VAULT_PATH/log.md"

# Update 'updated' date
sed -i "s/^updated: .*/updated: $DATE/" "$VAULT_PATH/log.md"
```

Or manually prepend:

```markdown
## 2026-10-24: Added new note on git sync patterns

Created [[multi-agent-git-sync]] covering explicit-path staging and rebase patterns.

Agent: [[Agents/coding-bot/README]]

---

## 2026-10-23: Processed inbox captures

(Previous entry...)
```

### Log entry format

```markdown
## YYYY-MM-DD: <brief-description>

<Details: what changed, why, what notes affected>

<Links to notes: [[note-name]]>

<Optional: Agent or person who made the change>
```

Keep entries concise. Full details live in the notes themselves.

## Project-specific logs

For `Projects/<project>/` work, also update the project's log:

```bash
PROJECT="project-name"
DATE=$(date +%Y-%m-%d)

# Append to project log (newest at top, usually)
cat >> "$VAULT_PATH/Projects/$PROJECT/${PROJECT}-log.md" << EOF

## $DATE: <agent-name>

What you did on this project.

Link: [[Agents/your-agent-name/outputs/YYYY-MM-DD-output]]

EOF
```

Or if the project hub has a Log section:

```markdown
# Project Name

## Log

### 2026-10-24: <agent-name>

Updated project with new findings from [[research-output]].

### 2026-10-23: ...

(Previous entries)
```

## Maintenance workflow

### After creating a new note

```bash
#!/usr/bin/env bash
set -euo pipefail

VAULT_PATH="${VAULT_PATH:-/vault}"
NOTE_PATH="Notes/new-note.md"  # Path relative to vault root
NOTE_NAME="new-note"            # Without .md extension
NOTE_DESC="Brief description"   # One-line description
AGENT_NAME="your-agent-name"
DATE=$(date +%Y-%m-%d)

cd "$VAULT_PATH"

# 1. Create the note (already done via write-note skill)

# 2. Add to index.md
# Find Notes section, add entry
echo "- [[${NOTE_NAME}]] — ${NOTE_DESC}" >> /tmp/index-entry.txt
sed -i '/^## Notes$/r /tmp/index-entry.txt' index.md
sed -i "s/^updated: .*/updated: $DATE/" index.md

# 3. Add to log.md
cat > /tmp/log-entry.txt << LOGEOF

## $DATE: Created [[${NOTE_NAME}]]

${NOTE_DESC}

Added by: [[Agents/${AGENT_NAME}/README]]

LOGEOF

sed -i '/^# Vault Log$/r /tmp/log-entry.txt' log.md
sed -i "s/^updated: .*/updated: $DATE/" log.md

# 4. Commit the note + index + log together
git add -- "$NOTE_PATH" index.md log.md
git commit -m "${AGENT_NAME}: add ${NOTE_NAME} and update index/log"
git pull --rebase --autostash origin main
git push
```

### After modifying an existing note

```bash
# Modify the note (already done)

# Add log entry only (don't duplicate in index)
DATE=$(date +%Y-%m-%d)
AGENT_NAME="your-agent-name"
NOTE_NAME="existing-note"

cat > /tmp/log-entry.txt << EOF

## $DATE: Updated [[${NOTE_NAME}]]

Added section on <topic>. Expanded <area>.

Updated by: [[Agents/${AGENT_NAME}/README]]

EOF

sed -i '/^# Vault Log$/r /tmp/log-entry.txt' "$VAULT_PATH/log.md"
sed -i "s/^updated: .*/updated: $DATE/" "$VAULT_PATH/log.md"

# Commit note + log
git add -- "Notes/${NOTE_NAME}.md" log.md
git commit -m "${AGENT_NAME}: update ${NOTE_NAME}"
```

## Checking if maintenance is needed

Before committing changes to `Notes/`, `Ideas/`, or `Projects/`:

```bash
# Check if note is already in index
NOTE_NAME="note-name"
grep -q "\[\[${NOTE_NAME}\]\]" "$VAULT_PATH/index.md"
if [ $? -ne 0 ]; then
  echo "⚠️  $NOTE_NAME not in index.md — add it"
fi

# Check if there's a log entry today for this note
DATE=$(date +%Y-%m-%d)
grep -q "## $DATE:.*\[\[${NOTE_NAME}\]\]" "$VAULT_PATH/log.md"
if [ $? -ne 0 ]; then
  echo "⚠️  No log entry today for $NOTE_NAME — add it"
fi
```

## When to skip maintenance

### Your own agent folder

Changes to `Agents/<name>/` don't go in vault index/log. Your `README.md` is your own log.

### Inbox, Daily, raw

- `Inbox/` — Staging area; not indexed until processed into Notes/Ideas
- `Daily/` — Transient; not indexed
- `raw/` — Immutable sources; registered in `raw/README.md` or project-specific README, not main index

### Trivial changes

Typo fixes, formatting, adding a single link: skip log entry.

### During batch processing

If processing many inbox items at once:

```markdown
## 2026-10-24: Processed 8 inbox captures

Created new notes:
- [[note-one]]
- [[note-two]]
- [[note-three]]

Updated:
- [[existing-note]] — Added insights from recent captures

Agent: [[Agents/research-bot/README]]
```

One log entry covering the batch, not one per note.

## Integration with other skills

### write-note + maintenance

```bash
# 1. Use write-note to create the note
NOTE_FILE="$VAULT_PATH/Notes/new-pattern.md"
cat > "$NOTE_FILE" << 'EOF'
---
type: note
created: 2026-10-24
tags: [git, patterns]
---

# Multi-Agent Git Sync Pattern

Pattern content...
EOF

# 2. Use maintenance to register it
# Add to index
sed -i '/^## Notes$/a- [[new-pattern]] — Multi-agent git sync pattern' \
  "$VAULT_PATH/index.md"

# Add to log
cat > /tmp/log-entry.txt << 'EOF'

## 2026-10-24: Created [[new-pattern]]

Documented multi-agent git sync pattern: explicit paths, rebase, retries.

Agent: [[Agents/coding-bot/README]]

EOF

sed -i '/^# Vault Log$/r /tmp/log-entry.txt' "$VAULT_PATH/log.md"

# 3. Use safe-sync to commit everything
./scripts/vault-sync.sh "coding-bot: add git sync pattern" \
  Notes/new-pattern.md index.md log.md
```

### Processing inbox

When promoting inbox captures to Notes:

```bash
# 1. Read inbox item
INBOX_FILE="$VAULT_PATH/Inbox/2026-10-23-capture.md"

# 2. Create atomic notes from it (write-note)
# ... create Notes/idea-one.md, Notes/idea-two.md

# 3. Update index with ALL new notes
# (add each to index.md)

# 4. Add ONE log entry covering the batch
cat > /tmp/log-entry.txt << 'EOF'

## 2026-10-24: Processed inbox capture from 2026-10-23

Created atomic notes:
- [[idea-one]] — First extracted idea
- [[idea-two]] — Second extracted idea

Source: [[Inbox/2026-10-23-capture]]

Agent: [[Agents/research-bot/README]]

EOF

sed -i '/^# Vault Log$/r /tmp/log-entry.txt' "$VAULT_PATH/log.md"

# 5. Commit: new notes + index + log (leave inbox item in place)
git add -- Notes/idea-one.md Notes/idea-two.md index.md log.md
git commit -m "research-bot: process inbox capture into atomic notes"
```

## Automated maintenance script

```bash
#!/usr/bin/env bash
# vault-maintain.sh - Update index and log after creating/modifying a note

set -euo pipefail

VAULT_PATH="${VAULT_PATH:-/vault}"
NOTE_PATH="$1"         # e.g. Notes/new-note.md
NOTE_DESC="$2"         # Brief description
SECTION="${3:-Notes}"  # Notes, Ideas, Projects, Resources
ACTION="${4:-created}" # created or updated
AGENT_NAME="${AGENT_NAME:-agent}"

cd "$VAULT_PATH"

# Extract note name (without .md)
NOTE_NAME=$(basename "$NOTE_PATH" .md)
DATE=$(date +%Y-%m-%d)

# Update index if created (not if just updated)
if [ "$ACTION" = "created" ]; then
  echo "Adding [[${NOTE_NAME}]] to index.md..."
  sed -i "/^## ${SECTION}\$/a- [[${NOTE_NAME}]] — ${NOTE_DESC}" index.md
  sed -i "s/^updated: .*/updated: $DATE/" index.md
fi

# Add log entry
echo "Adding log entry for [[${NOTE_NAME}]]..."
cat > /tmp/log-entry.txt << LOGEOF

## $DATE: ${ACTION^} [[${NOTE_NAME}]]

${NOTE_DESC}

Agent: [[Agents/${AGENT_NAME}/README]]

LOGEOF

sed -i '/^# Vault Log$/r /tmp/log-entry.txt' log.md
sed -i "s/^updated: .*/updated: $DATE/" log.md

echo "✅ Maintenance complete"
echo "Remember to commit: $NOTE_PATH index.md log.md"
```

Usage:

```bash
# After creating a note
vault-maintain.sh Notes/new-note.md "Brief description" Notes created

# After updating a note
vault-maintain.sh Notes/existing.md "Added new section" Notes updated

# Then commit
vault-sync.sh "agent-name: add new-note and update index/log" \
  Notes/new-note.md index.md log.md
```

## Troubleshooting

### index.md merge conflicts

If multiple agents add to index simultaneously:

```bash
# After pull --rebase conflicts
git status  # See index.md conflict

# Edit index.md, keep both additions, fix markers
# <<<<<<< ======= >>>>>>>

# Mark resolved
git add index.md
git rebase --continue
git push
```

### log.md conflicts

Same as index: keep both entries, sort by date (newest first).

### Forgot to update index/log

Add them retroactively:

```bash
# Note was created days ago, forgot to index
NOTE_NAME="forgotten-note"

# Add to index now
sed -i '/^## Notes$/a- [[forgotten-note]] — Description' index.md

# Add backdated log entry
cat > /tmp/log-entry.txt << 'EOF'

## 2026-10-20: Created [[forgotten-note]]

(Backdated entry: note created 2026-10-20, indexed 2026-10-24)

Description.

EOF

sed -i '/^# Vault Log$/r /tmp/log-entry.txt' log.md

# Commit the index/log update
vault-sync.sh "agent: backdate index/log for forgotten-note" index.md log.md
```

## Checklist

After creating a note in `Notes/`, `Ideas/`, or `Projects/`:

- [ ] Note has proper frontmatter and content
- [ ] Note is added to `index.md` under the right section
- [ ] Log entry added to `log.md` (newest at top)
- [ ] If project work: entry also in project's log
- [ ] Frontmatter `updated` dates refreshed in index.md and log.md
- [ ] Committed together: note + index.md + log.md

After updating a note:

- [ ] Changes are substantive (not just typos)
- [ ] Log entry added (updated, not created)
- [ ] Committed together: note + log.md

When to skip:

- [ ] Changes to `Agents/<name>/` (use agent README instead)
- [ ] Changes to `Inbox/`, `Daily/`, `raw/` (not indexed)
- [ ] Trivial edits (typos, formatting)
- [ ] Note already indexed (for updates, only log)
