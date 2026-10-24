---
name: bootstrap-vault
description: Set up a new Obsidian vault from scratch with proper folder structure, protocol file, templates, and git configuration. Use when a user needs to create their first second-brain vault.
---

# Bootstrap Vault

Create a new Obsidian vault from scratch with the proper folder structure, protocol, templates, and git setup for multi-agent use.

## When to bootstrap

Use this skill when:

- User wants to start using the second-brain plugin but has no vault
- Vault path exists but is empty or not initialized
- User asks to "set up" or "create" an Obsidian vault
- `AGENTS.md` doesn't exist at `$VAULT_PATH`

## Quick bootstrap

```bash
#!/usr/bin/env bash
set -euo pipefail

VAULT_PATH="${VAULT_PATH:-/vault}"
VAULT_NAME="${VAULT_NAME:-second-brain}"

# Create vault directory
mkdir -p "$VAULT_PATH"
cd "$VAULT_PATH"

# Initialize git
git init
git config user.name "${GIT_USER_NAME:-AI Agent}"
git config user.email "${GIT_USER_EMAIL:-agent@example.com}"

# Create folder structure
mkdir -p 00-Core
mkdir -p Agents
mkdir -p Daily
mkdir -p Ideas
mkdir -p Inbox
mkdir -p Notes
mkdir -p Projects
mkdir -p Resources
mkdir -p Templates
mkdir -p _archive
mkdir -p raw
mkdir -p scripts

echo "Vault structure created at $VAULT_PATH"
```

## Complete bootstrap script

```bash
#!/usr/bin/env bash
# bootstrap-vault.sh - Create a new second-brain vault

set -euo pipefail

VAULT_PATH="${VAULT_PATH:-/vault}"
VAULT_NAME="${VAULT_NAME:-second-brain}"

echo "=== Bootstrapping Second Brain Vault ==="
echo "Location: $VAULT_PATH"
echo

# Check if vault already exists
if [ -f "$VAULT_PATH/AGENTS.md" ]; then
  echo "❌ Vault already exists at $VAULT_PATH (AGENTS.md found)"
  echo "To re-bootstrap, remove or rename the existing vault first."
  exit 1
fi

# Create vault directory
mkdir -p "$VAULT_PATH"
cd "$VAULT_PATH"

# Initialize git if not already a repo
if [ ! -d .git ]; then
  echo "Initializing git repository..."
  git init
  git config user.name "${GIT_USER_NAME:-AI Agent}"
  git config user.email "${GIT_USER_EMAIL:-agent@example.com}"
fi

# Create folder structure
echo "Creating folder structure..."
mkdir -p 00-Core
mkdir -p Agents
mkdir -p Daily
mkdir -p Ideas
mkdir -p Inbox
mkdir -p Notes
mkdir -p Projects
mkdir -p Resources
mkdir -p Templates
mkdir -p _archive
mkdir -p raw
mkdir -p scripts

# Create AGENTS.md (protocol file)
cat > AGENTS.md << 'PROTOCOL_EOF'
---
type: protocol
applies_to: all agents
updated: $(date +%Y-%m-%d)
---
# Agent Protocol

Every agent follows these rules on **every session and every new task**.

## 1. Start of session: pull, then read

\`\`\`bash
cd $VAULT_PATH
git pull --rebase --autostash origin main
\`\`\`

Then read, in order:
1. \`AGENTS.md\` (this file)
2. [[00-Core/Profile]]
3. [[00-Core/Preferences]]
4. [[00-Core/Active-Projects]]
5. Your own notes in \`Agents/<name>/README.md\`
6. When the task touches the knowledge base: [[index]] and [[log]]

## 2. Write scope

- Write **only** to your own \`Agents/<name>/\` folder, \`Inbox/\`, or \`Daily/\`
- Edits to \`00-Core/\` go through a proposal note in \`Inbox/\` unless explicitly asked
- Do not edit or delete another agent's folder
- \`raw/\` is **read-only** for every agent
- Don't create new top-level folders without asking
- Don't delete files; archive instead (move to \`_archive/\`)
- Don't rename files unless explicitly asked (breaks wikilinks)

### Agent folder layout

\`\`\`
Agents/<name>/
  README.md        # Role, rules, routines, learnings log
  outputs/         # Dated outputs: YYYY-MM-DD-<type>-<slug>.md
  assets/          # Images/media: kebab-case, date-prefixed
  data/            # CSV/JSON/TXT working data
\`\`\`

## 3. After writing: commit, rebase, push

Use the sync script with explicit paths only:

\`\`\`bash
./scripts/vault-sync.sh "<agent-name>: <message>" <path> [<path> ...]
\`\`\`

Or manually:
\`\`\`bash
git add -- <explicit-paths-only>  # Never git add -A or git add .
git commit -m "<agent-name>: <description>"
git pull --rebase --autostash origin main
git push
\`\`\`

**Critical:** Multiple agents write here concurrently. NEVER use \`git add -A\` or \`git add .\`.

## 4. No secrets

Never store secrets, API keys, tokens, or passwords in the vault.

## 5. Vault beats memory

Facts in the vault override an agent's memory. If you believe a vault fact is wrong, propose a correction in \`Inbox/\` rather than acting on your memory.

## 6. Knowledge base rules

| Folder | Purpose | Who writes |
|---|---|---|
| \`Inbox/\` | Raw captures, proposals | Any agent, automation |
| \`Daily/\` | Daily notes | Any agent |
| \`Notes/\` | Atomic, evergreen notes | Per routing rules |
| \`Ideas/\` | Synthesis, questions, hypotheses | Per routing rules |
| \`Projects/<project>/\` | Project-specific work | Per routing rules |
| \`raw/<project>/\` | Source material (PDFs, articles) | Read-only for agents |
| \`_archive/\` | Archived files | When archiving |

### File conventions

- Filenames: \`kebab-case.md\` (no spaces, no underscores)
- Dated files: \`YYYY-MM-DD-<slug>.md\` (date first)
- Frontmatter: required (see Templates/)
- Links: \`[[wikilinks]]\`, not markdown links
- One idea per note (~400 words max)
- Logs are append-only (newest at top)

### Frontmatter

\`\`\`yaml
---
type: note           # controlled list
created: YYYY-MM-DD
tags: [topic1]       # controlled list
project: <name>      # if applicable
source: URL or [[raw/file]]  # if applicable
---
\`\`\`

### Index and log upkeep

When you add or modify a note in \`Notes/\`, \`Ideas/\`, or \`Projects/\`:
- Register it in [[index]]
- Add a dated entry to [[log]] (newest at top)

### Routing rules

- Article/transcript → Save to \`raw/\`, create atomic Notes citing it
- New idea → \`Ideas/\` (hypothesis) or \`Notes/\` (fact)
- Work context → \`Projects/<project>/\` with log entry
- Decision → Project page and project log
- Contradiction → Don't overwrite; add "Contradictions" section

## Agent names

When you first work in this vault, create your agent folder:

\`\`\`bash
mkdir -p Agents/<your-name>
cat > Agents/<your-name>/README.md << 'EOF'
# <Your Agent Name>

## Role

<Your role and purpose>

## Learnings Log

### $(date +%Y-%m-%d): First session

Initial setup.

EOF

mkdir -p Agents/<your-name>/outputs
mkdir -p Agents/<your-name>/assets
mkdir -p Agents/<your-name>/data
\`\`\`

Choose a clear, descriptive agent name: \`research-bot\`, \`coding-assistant\`, \`email-helper\`, etc.
PROTOCOL_EOF

# Create 00-Core files
cat > 00-Core/Profile.md << 'EOF'
---
type: core
updated: $(date +%Y-%m-%d)
---
# Profile

**Name:** [Your name]

## Context

[Brief background: what you do, what you're working on, what matters to you]

## Current Focus

[What you're focused on right now]
EOF

cat > 00-Core/Preferences.md << 'EOF'
---
type: core
updated: $(date +%Y-%m-%d)
---
# Preferences

## Communication Style

[How you like agents to communicate with you]

## Working Style

[When you work, how you organize, what you prefer]

## Decision-Making

[How you make decisions, what you value]
EOF

cat > 00-Core/Active-Projects.md << 'EOF'
---
type: core
updated: $(date +%Y-%m-%d)
---
# Active Projects

## Current Projects

[List your active projects here. Link to Projects/ folders.]

## Planned

[Projects in planning]

## Paused

[Projects on hold]
EOF

# Create index.md
cat > index.md << 'EOF'
---
type: index
updated: $(date +%Y-%m-%d)
---
# Vault Index

## Core

- [[AGENTS]]
- [[00-Core/Profile]]
- [[00-Core/Preferences]]
- [[00-Core/Active-Projects]]

## Notes

(Register atomic notes here)

## Ideas

(Register ideas and hypotheses here)

## Projects

(Register project hubs here)

## Resources

(Register resources here)
EOF

# Create log.md
cat > log.md << 'EOF'
---
type: log
updated: $(date +%Y-%m-%d)
---
# Vault Log

Append-only log of vault changes. Newest entries at top.

## $(date +%Y-%m-%d): Vault bootstrapped

Vault created and initialized.

EOF

# Create README files for special folders
cat > _archive/README.md << 'EOF'
# Archive

Archived files are stored here at their original path:
- \`_archive/Notes/old-note.md\`
- \`_archive/Projects/old-project/\`

Never delete files outright; archive them instead to preserve history.
EOF

cat > raw/README.md << 'EOF'
# Raw Sources

Source materials: PDFs, articles, transcripts, decks, workbooks.

- Organized by project: \`raw/<project-name>/\`
- Files are immutable: don't edit in place
- Read-only for agents
- To update a source: replace the whole file

Register each file in this README or a project-specific \`raw/<project>/README.md\`.
EOF

cat > Resources/README.md << 'EOF'
# Resources

Reference material, guides, links, tool docs.
EOF

# Create Templates
cat > Templates/Note.md << 'EOF'
---
type: note
created: YYYY-MM-DD
tags: []
source: 
---

# Title

Content.

## Links

- [[related-note]]
EOF

cat > Templates/Agent-Output.md << 'EOF'
---
type: agent-output
agent: <name>
created: YYYY-MM-DD
tags: []
project: 
---

# Title

Output content.

## Links

- [[related]]
EOF

cat > Templates/Proposal.md << 'EOF'
---
type: proposal
status: open
created: YYYY-MM-DD
agent: <name>
---

# Proposal: <title>

## Motivation

Why?

## Proposed Change

What to change in \`00-Core/\`.

## Impact

What this affects.
EOF

cat > Templates/Project-Hub.md << 'EOF'
---
type: project
status: active
created: YYYY-MM-DD
tags: []
---

# Project Name

## Overview

What is this project?

## Status

Current status and next steps.

## Links

- [[related-note]]

## Log

### YYYY-MM-DD: Started

Project initiated.
EOF

cat > Templates/Daily.md << 'EOF'
---
type: daily
created: YYYY-MM-DD
---

# YYYY-MM-DD

## Notes

## Tasks

## Links

EOF

# Create vault-sync script
cat > scripts/vault-sync.sh << 'SYNC_EOF'
#!/usr/bin/env bash
# Sync the vault: stage ONLY the paths you list, commit, pull --rebase, push.
# Usage: vault-sync.sh "<agent-name>: <message>" <path> [<path> ...]
set -euo pipefail

VAULT_PATH="${VAULT_PATH:-$(pwd)}"
REMOTE="${VAULT_REMOTE:-origin}"
BRANCH="${VAULT_BRANCH:-main}"

cd "$VAULT_PATH" || exit 1

if [ $# -lt 2 ]; then
  echo "Usage: vault-sync.sh \"<agent-name>: <message>\" <path> [<path> ...]" >&2
  exit 2
fi

MSG="$1"
shift

git add -- "$@" || exit 1

if git diff --cached --quiet; then
  echo "Nothing to commit."
else
  git commit -m "$MSG" || exit 1
fi

git remote get-url "$REMOTE" >/dev/null 2>&1 || {
  echo "No remote '$REMOTE'; skipping push."
  exit 0
}

for i in 1 2 3; do
  if git pull --rebase --autostash "$REMOTE" "$BRANCH"; then
    break
  fi
  echo "pull failed (attempt $i), retrying..." >&2
  sleep 5
  if [ $i = 3 ]; then
    echo "pull --rebase failed; resolve manually" >&2
    exit 1
  fi
done

git push || {
  echo "push failed" >&2
  exit 1
}
SYNC_EOF

chmod +x scripts/vault-sync.sh

# Create .gitignore
cat > .gitignore << 'EOF'
.obsidian/workspace*
.obsidian/cache
.DS_Store
*.tmp
EOF

# Initial commit
git add .
git commit -m "init: bootstrap second-brain vault"

echo
echo "✅ Vault bootstrapped successfully!"
echo
echo "Next steps:"
echo "1. Edit 00-Core/Profile.md with your information"
echo "2. Edit 00-Core/Preferences.md with your preferences"
echo "3. Create your first agent folder: mkdir -p Agents/<agent-name>"
echo "4. Add a git remote: git remote add origin <url>"
echo "5. Push: git push -u origin main"
echo
echo "Vault location: $VAULT_PATH"
```

## Folder structure explained

```
vault/
├── .git/                    # Git repository
├── .gitignore              # Ignore Obsidian workspace files
├── AGENTS.md               # Master protocol (read first)
├── index.md                # Vault index
├── log.md                  # Vault change log
│
├── 00-Core/                # Core user files
│   ├── Profile.md
│   ├── Preferences.md
│   └── Active-Projects.md
│
├── Agents/                 # Per-agent folders
│   └── <agent-name>/
│       ├── README.md       # Agent role, rules, learnings
│       ├── outputs/        # Dated outputs
│       ├── assets/         # Media files
│       └── data/           # Working data
│
├── Daily/                  # Daily notes
├── Ideas/                  # Hypotheses, open questions
├── Inbox/                  # Captures, proposals
├── Notes/                  # Atomic evergreen notes
├── Projects/               # Project folders
├── Resources/              # Reference material
├── Templates/              # Note templates
├── _archive/               # Archived files
├── raw/                    # Source materials (read-only)
└── scripts/                # Helper scripts
    └── vault-sync.sh       # Safe sync script
```

## Obsidian configuration (optional)

For users with Obsidian desktop, recommend these settings:

### Core plugins to enable

- **Files & Links**
  - Auto-update internal links: ON
  - Default location for new notes: Vault folder
- **Templates**
  - Template folder: Templates
- **Daily notes**
  - Daily note template: Templates/Daily
  - Date format: YYYY-MM-DD

### Community plugins

- **Obsidian Git** (auto-sync)
  - Vault backup interval: 10 minutes
  - Auto pull interval: 5 minutes
  - Commit message: "vault: auto-commit {{date}}"
  
  **Important:** Configure Obsidian Git to NOT use `git add -A`. Instead:
  - Disable "Commit all changes" option
  - Or configure it to commit only changed files, not untracked ones

- **Templater** (advanced templates, optional)
- **Dataview** (query notes, optional)

### Settings to create

Create `.obsidian/app.json` (optional, for Obsidian desktop users):

```json
{
  "newFileLocation": "folder",
  "newFileFolderPath": "Inbox",
  "attachmentFolderPath": "raw",
  "useMarkdownLinks": false,
  "showUnsupportedFiles": false
}
```

## Post-bootstrap checklist

After running bootstrap:

1. **Customize 00-Core files**
   - [ ] Edit `00-Core/Profile.md` with user information
   - [ ] Edit `00-Core/Preferences.md` with user preferences
   - [ ] Add projects to `00-Core/Active-Projects.md`

2. **Set up git remote**
   - [ ] Create a private git repo (GitHub, GitLab, etc.)
   - [ ] Add remote: `git remote add origin <url>`
   - [ ] Push: `git push -u origin main`

3. **Create first agent folder**
   - [ ] Choose your agent name
   - [ ] Create `Agents/<name>/` with README.md
   - [ ] Create subfolders: outputs/, assets/, data/

4. **Test the sync workflow**
   - [ ] Make a change (edit a file)
   - [ ] Use vault-sync.sh to commit and push
   - [ ] Verify it appears in remote repo

5. **Configure Obsidian (if used)**
   - [ ] Open vault in Obsidian desktop
   - [ ] Enable recommended plugins
   - [ ] Configure Obsidian Git (if auto-sync desired)

## Integration with the plugin

After bootstrap, the vault is ready for the second-brain plugin:

1. **Set environment variable**
   ```bash
   export VAULT_PATH=/path/to/vault
   ```

2. **Test session start**
   ```bash
   cd "$VAULT_PATH"
   git pull --rebase --autostash origin main
   cat AGENTS.md
   ```

3. **Create your agent folder**
   ```bash
   mkdir -p Agents/your-agent-name/{outputs,assets,data}
   cat > Agents/your-agent-name/README.md << 'EOF'
   # Your Agent Name
   
   ## Role
   
   [Your role]
   
   ## Learnings Log
   
   ### $(date +%Y-%m-%d): First session
   
   Vault initialized and ready.
   EOF
   ```

4. **Start using the vault**
   - Load `vault-session-start` skill at start of each session
   - Use `write-note` to create outputs
   - Use `safe-sync` to commit changes
   - Use `capture-learning` to log learnings

## Troubleshooting

**Bootstrap fails: directory not empty**

If `$VAULT_PATH` exists and isn't empty:

```bash
# Backup existing content
mv "$VAULT_PATH" "${VAULT_PATH}.backup"

# Bootstrap fresh
# ... run bootstrap script ...

# Migrate old content if needed
cp -r "${VAULT_PATH}.backup"/* "$VAULT_PATH/"
```

**Git remote already exists**

If git remote is already configured, skip the `git remote add` step:

```bash
git remote -v  # Check existing remotes
git push -u origin main  # Push to existing remote
```

**Permission denied on scripts**

Make sure sync script is executable:

```bash
chmod +x "$VAULT_PATH/scripts/vault-sync.sh"
```

**Obsidian Git conflicts with agent commits**

Configure Obsidian Git to:
- NOT commit untracked files
- Pull before push
- Use rebase, not merge
- Or disable Obsidian Git and let agents handle sync
