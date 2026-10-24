---
name: write-note
description: Create or update notes in the vault following proper conventions for filenames, frontmatter, wikilinks, and agent folder structure. Use when creating outputs, capturing learnings, or processing inbox items.
---

# Write Note

Create and update vault notes following the vault's conventions. This skill covers frontmatter, naming, wikilinks, and where files belong.

## File naming conventions

### For dated outputs (in your `Agents/<name>/outputs/`)

```
YYYY-MM-DD-<type>-<slug>.md
```

Examples:
- `2026-10-24-daily-replies.md`
- `2026-10-24-analysis-github-trends.md`
- `2026-10-flight-apis.md` (coarsest date for month/trip outputs)

### For knowledge base notes (`Notes/`, `Ideas/`, `Projects/`)

```
kebab-case-title.md
```

- Lowercase, hyphens only
- No spaces, no underscores, no special characters
- Descriptive and unique across the vault
- Examples: `llm-wiki-pattern.md`, `rag-vs-llm-wiki.md`, `voice-fidelity-question.md`

### Basename uniqueness

Basenames should be unique across the vault. Where they can't be (`README.md`, `memory.md`), use the full path in wikilinks:

```markdown
[[Agents/claude-desktop/projects/mm/chats]]
```

## Frontmatter

Every note requires frontmatter with controlled keys:

```yaml
---
type: agent-output           # See types below
agent: <your-agent-name>     # Required for agent-output
project: <project-name>      # Optional: a Projects/<project>/ folder name
created: YYYY-MM-DD
tags: [topic1, topic2]       # Controlled list only, never type/project names
keywords: [free, words]      # Optional, free-form
source: [[raw/project/file]] or URL  # Optional
status: open                 # Required for proposals, optional for projects
---
```

### Controlled types

Use these exact values for `type`:
- `agent-output` — Your dated output files
- `note` — Atomic evergreen notes
- `idea` — Hypotheses, open questions
- `project` — Project hub files
- `workstream` — Project workstreams
- `project-doc` — Project documentation
- `source` — Raw sources in `raw/`
- `chat-summary` — Chat summaries
- `proposal` — Proposals for core changes
- `protocol` — Protocol files like `AGENTS.md`
- `daily` — Daily notes

### Status values (for proposals and projects)

**Proposals** (required):
- `open` — Under review
- `applied` — Implemented
- `rejected` — Declined
- `superseded` — Replaced by another proposal

**Projects** (optional):
- `active` — Currently working
- `planning` — In planning phase
- `paused` — Temporarily on hold
- `done` — Completed

Add `archived: true` to frontmatter when archiving.

## Agent folder structure

```
Agents/<your-name>/
├── README.md           # Role, rules, routines, newest-first notes log
├── outputs/            # Dated outputs go here
│   ├── YYYY-MM-DD-<type>-<slug>.md
│   └── ...
├── assets/             # Images/media you produced
│   └── YYYY-MM-DD-<name>.png
├── data/               # CSV/JSON/TXT working data
│   └── file.csv
└── <working>.md        # Optional standing working docs
```

**Rules:**
- New dated outputs go in `outputs/`, never loose next to `README.md`
- Use frontmatter template with `type: agent-output` and `agent: <name>`
- Commit everything you create; never leave untracked files
- Link your outputs in your `README.md` (newest first)

## Wikilinks

Use `[[wikilinks]]`, not markdown links, so Obsidian's graph picks them up:

```markdown
Good: [[note-name]]
Good: [[note-name|display text]]
Good: [[folder/note-name]]  # When basename isn't unique

Bad: [note-name](note-name.md)
```

## Writing rules

### One idea per note

If a note grows past ~400 words, split it into multiple atomic notes and link them.

### Logs are append-only

For `log.md` and `<project>-log.md` files: **never rewrite history**. Add dated entries at the top, newest first.

### Preserve existing content

- Don't "clean up" notes you weren't asked to touch
- Unsolicited cleanup breaks wikilinks
- When asked to move/rename: use `git mv` and rewrite every wikilink in the same commit

### Contradictions

If you find something that contradicts an existing note:
- **Don't overwrite**
- Add a "Contradictions" section to the affected note
- Link both sides with wikilinks

## Where things go (routing rules)

When creating notes based on new content:

| Content type | Destination | Notes |
|---|---|---|
| Your own output | `Agents/<name>/outputs/` | With agent-output frontmatter |
| Raw article/transcript | `Inbox/` first | Then create atomic Notes citing it |
| User's new idea | `Ideas/` or `Notes/` | Idea = hypothesis/question; Note = fact |
| Work context | `Projects/<project>/` | Add entry to project log |
| Decision | `Projects/<project>/` + log | Both hub and append-only log |
| Proposal for `00-Core/` | `Inbox/YYYY-MM-DD-<agent>-<topic>.md` | With proposal frontmatter |

## Templates

Use these templates (from `Templates/` folder):

### Agent Output Template

```markdown
---
type: agent-output
agent: <name>
project: <project-name>  # if applicable
created: YYYY-MM-DD
tags: []
---

# Title

Content here.

## Links

- [[Related-Note-1]]
- [[Related-Note-2]]
```

### Note Template

```markdown
---
type: note
created: YYYY-MM-DD
tags: [topic]
source: URL or [[raw/file]]
---

# Title

One atomic idea per note.

## Links

- [[related-note]]
```

### Proposal Template

```markdown
---
type: proposal
status: open
created: YYYY-MM-DD
agent: <name>
---

# Proposal: <title>

## Motivation

Why this change?

## Proposed Change

What to change in `00-Core/`.

## Impact

What this affects.
```

## Examples

### Creating an agent output

```bash
VAULT_PATH="${VAULT_PATH:-/vault}"
AGENT_NAME="research-bot"
DATE=$(date +%Y-%m-%d)
FILE="$VAULT_PATH/Agents/$AGENT_NAME/outputs/$DATE-analysis-obsidian-plugins.md"

cat > "$FILE" << 'EOF'
---
type: agent-output
agent: research-bot
created: 2026-10-24
tags: [obsidian, plugins, research]
---

# Obsidian Plugin Analysis

Analysis content here...

## Findings

1. Finding one
2. Finding two
EOF

# Link it in your README (newest first)
echo "- [[$DATE-analysis-obsidian-plugins]] — Plugin analysis" >> "$VAULT_PATH/Agents/$AGENT_NAME/README.md"
```

### Creating a proposal for 00-Core

```bash
VAULT_PATH="${VAULT_PATH:-/vault}"
AGENT_NAME="coding-bot"
DATE=$(date +%Y-%m-%d)
FILE="$VAULT_PATH/Inbox/$DATE-$AGENT_NAME-update-active-projects.md"

cat > "$FILE" << 'EOF'
---
type: proposal
status: open
created: 2026-10-24
agent: coding-bot
---

# Proposal: Add new project to Active-Projects

## Motivation

New project started, needs tracking.

## Proposed Change

Add to `00-Core/Active-Projects.md`:
- **Project Name:** Description

## Impact

Agents will be aware of this project.
EOF
```

## Checklist before writing

- [ ] Vault is pulled and up to date (`vault-session-start`)
- [ ] You know your write scope (from `AGENTS.md`)
- [ ] Filename follows conventions (date-first for outputs, kebab-case for notes)
- [ ] Frontmatter is complete with controlled types and tags
- [ ] You're writing to the right location
- [ ] For agent outputs: going in `Agents/<name>/outputs/`
- [ ] For proposals: going in `Inbox/`
- [ ] For notes: going in `Notes/`, `Ideas/`, or `Projects/` per routing rules
- [ ] Using `[[wikilinks]]` not markdown links
- [ ] Will commit only your own files (see `safe-sync`)
