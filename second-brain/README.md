# Second Brain

> Shared, user-owned memory for AI agents in a plain-markdown Obsidian vault synced through git.

A Cursor/Grok Bot marketplace plugin that gives any team of AI agents persistent context, learned patterns, and a growing knowledge base. Unlike hosted memory solutions (Mem0, Supermemory, Vertiso), your second brain lives in a git repository you control, using plain markdown files that Obsidian can visualize and edit.

## What it does

Implements the **Karpathy LLM-wiki pattern**: agents maintain a linked graph of atomic, evergreen notes that compound over time. Multiple agents read from and contribute to a shared vault following a clear protocol.

### Core capabilities

- **Session start**: Pull the vault safely and read protocol + core notes before any task
- **Writing notes**: Per-agent folders, date-first kebab-case filenames, frontmatter, wikilinks, Inbox for proposed core changes
- **Safe sync**: Commit with an `<agent>:` prefix using explicit paths only (never `git add -A`), rebase-then-push with retries, conflict handling
- **Capture learnings**: Record errors, corrections, and decisions back to the vault (the self-improving agent pattern)
- **Maintenance**: Index and log upkeep, broken wikilink check
- **Bootstrap**: Set up a new vault with folder layout, protocol, and templates

## Skills

| Skill | Use when |
|---|---|
| **vault-session-start** | Start of every session and new task — pull, read protocol |
| **write-note** | Creating outputs, processing inbox, updating knowledge base |
| **safe-sync** | After any vault write — commit with explicit paths only |
| **capture-learning** | End of task — record what worked, what failed, patterns |
| **link-check** | Periodic maintenance — find broken wikilinks, orphan notes |
| **bootstrap-vault** | First-time setup — create vault structure from scratch |
| **maintenance** | After creating/modifying notes — update index.md and log.md |

## Why this plugin?

### Marketplace gap

ClawHub shows strong demand:
- **Obsidian skill**: 112k downloads
- **Ontology (typed knowledge graph)**: 201k downloads  
- **Self-improving agent**: 488k downloads

The Grok Bot marketplace (482 plugins) has **zero git-based memory** plugins. Existing memory solutions are hosted (Mem0, Supermemory, Vertiso) or proprietary (Heptabase, Craft).

### User-owned, portable, debuggable

- **Your data**: Lives in your private git repo, not a vendor's database
- **Plain text**: Markdown files you can read, edit, grep, and version
- **Obsidian-compatible**: Visualize the graph, use Obsidian plugins, edit manually
- **Multi-agent**: Explicit sync protocol prevents concurrent-write corruption

### Proven system

Based on a working 15-agent Obsidian vault. The attached protocol (`AGENTS.md`) and sync script (`sync.sh`) are the live rules generalized for the marketplace.

## Setup

### 1. Install the plugin

(Instructions for Cursor/Grok Bot marketplace installation TBD based on publishing process)

### 2. Configure vault path

```bash
export VAULT_PATH="/path/to/your/vault"
export VAULT_REMOTE="origin"      # optional, default: origin
export VAULT_BRANCH="main"        # optional, default: main
```

Or set in your Cursor/Grok Bot environment config.

### 3. Bootstrap a new vault (first-time users)

If you don't have an Obsidian vault yet:

```bash
# Agent will do this when you load the bootstrap-vault skill
# Or manually:
export VAULT_PATH="/path/to/new/vault"
# Load bootstrap-vault skill in your agent chat
```

This creates:
- Folder structure (`Agents/`, `Notes/`, `Ideas/`, `Projects/`, `Inbox/`, etc.)
- Protocol file (`AGENTS.md`)
- Core files (`00-Core/Profile.md`, `Preferences.md`, `Active-Projects.md`)
- Templates (`Templates/Note.md`, `Agent-Output.md`, etc.)
- Helper scripts (`scripts/vault-sync.sh`)
- Git repo with initial commit

### 4. Use with existing vault

If you already have an Obsidian vault:

1. **Ensure it's a git repo:**
   ```bash
   cd /path/to/vault
   git status  # Should show a repo
   ```

2. **Copy the protocol** (or adapt yours):
   - The plugin expects `AGENTS.md` at the vault root
   - See `skills/bootstrap-vault/SKILL.md` for the template

3. **Copy the sync script**:
   ```bash
   mkdir -p scripts
   cp /path/to/plugin/scripts/vault-sync.sh scripts/
   chmod +x scripts/vault-sync.sh
   ```

4. **Create your agent folder**:
   ```bash
   mkdir -p Agents/<your-agent-name>/{outputs,assets,data}
   cat > Agents/<your-agent-name>/README.md << 'EOF'
   # Your Agent Name
   
   ## Role
   
   [Your role]
   
   ## Learnings Log
   
   (Newest first)
   EOF
   ```

### 5. Configure git identity

The vault needs git user config:

```bash
cd "$VAULT_PATH"
git config user.name "Agent Name"
git config user.email "agent@example.com"
```

Or set globally:

```bash
export GIT_USER_NAME="Agent Name"
export GIT_USER_EMAIL="agent@example.com"
```

## Usage

### Typical agent workflow

```markdown
1. **Session start**
   - Agent loads `vault-session-start` skill
   - Pulls latest vault state
   - Reads `AGENTS.md`, core files, and own `Agents/<name>/README.md`

2. **Do work**
   - Agent performs task (research, coding, analysis)
   - Uses `write-note` skill to create outputs in `Agents/<name>/outputs/`
   - Follows vault conventions: frontmatter, wikilinks, kebab-case

3. **Sync changes**
   - Uses `safe-sync` skill or `vault-sync.sh` script
   - Stages only explicit paths (never `git add -A`)
   - Commits with `<agent-name>:` prefix
   - Rebases and pushes (3 retries if concurrent agents pushing)

4. **Capture learnings**
   - At task end, uses `capture-learning` skill
   - Logs what worked, what failed, patterns discovered
   - Updates `Agents/<name>/README.md` learnings log

5. **Maintenance (if touching knowledge base)**
   - If created/modified `Notes/`, `Ideas/`, or `Projects/`: uses `maintenance` skill
   - Registers note in `index.md`
   - Adds dated entry to `log.md`
```

### Example: Research agent using the vault

```yaml
Agent: research-bot
Task: Analyze GitHub plugin marketplace

Workflow:
1. Load vault-session-start
   - Pull vault
   - Read AGENTS.md, Agents/research-bot/README.md
   
2. Do research
   - Query GitHub, scrape data, analyze trends
   - Use write-note to create: Agents/research-bot/outputs/2026-10-24-github-analysis.md
   
3. Sync
   - vault-sync.sh "research-bot: add github analysis" \
       Agents/research-bot/outputs/2026-10-24-github-analysis.md \
       Agents/research-bot/README.md
   
4. Capture learning
   - Update Agents/research-bot/README.md with:
     ### 2026-10-24: Completed GitHub analysis
     Learnings:
     - GitHub API rate limits: 5000/hour authenticated
     - Plugin categories: skewed toward infra/data (60%)
     - Pattern: marketplace gaps correlate with ClawHub demand
```

## Concurrent multi-agent use

**The key rule**: Never `git add -A` or `git add .`

Multiple agents write to the vault simultaneously. Staging everything sweeps up their uncommitted work under your name, corrupting history.

### Safe sync pattern

```bash
# WRONG - breaks concurrent writes
git add -A
git commit -m "agent: changes"
git pull --rebase
git push

# RIGHT - explicit paths only
git add -- Agents/agent-name/ Inbox/specific-file.md
git commit -m "agent-name: changes"
git pull --rebase --autostash origin main  # 3 retries if needed
git push
```

The `vault-sync.sh` script implements this correctly:

```bash
./scripts/vault-sync.sh "agent-name: message" \
  Agents/agent-name/ \
  Inbox/2026-10-24-proposal.md
```

### Conflict handling

**If rebase conflicts in your files**: Resolve manually, then `git rebase --continue`.

**If rebase conflicts in files outside your scope**: Abort with `git rebase --abort`, then create a proposal in `Inbox/` instead of forcing.

## Vault structure

```
vault/
├── AGENTS.md                # Master protocol
├── index.md                 # Vault index
├── log.md                   # Change log (append-only)
│
├── 00-Core/                 # User core files
│   ├── Profile.md
│   ├── Preferences.md
│   └── Active-Projects.md
│
├── Agents/                  # Per-agent folders
│   ├── research-bot/
│   │   ├── README.md        # Role, rules, learnings log
│   │   ├── outputs/         # Dated outputs (YYYY-MM-DD-*.md)
│   │   ├── assets/          # Images, media
│   │   └── data/            # CSV, JSON, working data
│   └── coding-bot/
│       └── ...
│
├── Inbox/                   # Captures, proposals
├── Daily/                   # Daily notes
├── Notes/                   # Atomic evergreen notes
├── Ideas/                   # Hypotheses, questions
├── Projects/                # Project folders
│   └── project-name/
│       ├── project-name.md  # Hub
│       └── project-name-log.md  # Append-only log
│
├── Templates/               # Note templates
├── Resources/               # Reference material
├── raw/                     # Source files (read-only for agents)
├── _archive/                # Archived files
└── scripts/                 # Helper scripts
    └── vault-sync.sh
```

## File conventions

### Naming

- **Dated outputs**: `YYYY-MM-DD-<type>-<slug>.md` (date first)
- **Knowledge notes**: `kebab-case-title.md` (no spaces, no underscores)
- **No special chars**: Only lowercase letters, numbers, hyphens

### Frontmatter

Every note requires frontmatter:

```yaml
---
type: agent-output           # or note, idea, project, proposal, etc.
agent: <name>                # for agent-output
project: <project>           # if applicable
created: YYYY-MM-DD
tags: [topic1, topic2]       # controlled list
keywords: [free, words]      # optional, free-form
source: URL or [[raw/file]]  # optional
---
```

### Links

Use `[[wikilinks]]`, not markdown links:

```markdown
[[note-name]]                # Good
[[note-name|Display Text]]   # Good
[[folder/note-name]]         # Good for path-based

[note-name](note-name.md)    # Bad - breaks Obsidian graph
```

## Maintenance

### Link health check

Periodically or after bulk changes:

```bash
cd "$VAULT_PATH"
./scripts/vault-link-check.sh  # If you created this helper

# Or use the link-check skill
```

Finds:
- Broken wikilinks (links to non-existent files)
- Orphaned notes (files with no incoming links)

### Index and log upkeep

When adding/modifying `Notes/`, `Ideas/`, or `Projects/`:

1. Register in `index.md`
2. Add dated entry to `log.md` (newest at top)

The `maintenance` skill automates this.

## Obsidian integration (optional)

For human users with Obsidian desktop:

1. **Open the vault**: File → Open vault → `/path/to/vault`
2. **Enable plugins**:
   - Core: Files & Links, Templates, Daily notes
   - Community: Obsidian Git (for auto-sync)
3. **Configure Obsidian Git**:
   - Vault backup interval: 10 minutes
   - Auto pull interval: 5 minutes
   - **Important**: Disable "Commit all changes" or configure to NOT use `git add -A`

Obsidian gives you:
- Graph view of wikilinks
- Visual editor for notes
- Backlinks panel (what links here)
- Search across vault
- Canvas for visual organization

But agents work fine without Obsidian — it's just plain markdown + git.

## Comparison to alternatives

| Feature | Second Brain | Mem0 | Supermemory | Vertiso |
|---|---|---|---|---|
| **Storage** | Your git repo | Hosted DB | Hosted DB | Hosted DB |
| **Format** | Plain markdown | Proprietary | Proprietary | Proprietary |
| **Portability** | Full export anytime | API only | API only | API only |
| **Obsidian compat** | Yes | No | No | No |
| **Multi-agent sync** | Git protocol | API concurrency | API concurrency | API concurrency |
| **Version history** | Git log | Limited | Limited | Limited |
| **Cost** | Free (your infra) | Paid tiers | Paid tiers | Paid tiers |
| **Privacy** | Your control | Vendor ToS | Vendor ToS | Vendor ToS |
| **Graph view** | Obsidian | No | No | Limited |

## Testing

See `tests/` directory for:
- Throwaway vault creation
- Concurrent writer simulation
- Forced conflict handling
- Link check validation

Run tests:

```bash
cd /workspace/second-brain
./tests/test-plugin.sh
```

(Test suite created during development; see PR for results)

## Roadmap / future enhancements

- [ ] Dataview query helpers (SQL-like queries over frontmatter)
- [ ] Auto-tagging based on content analysis
- [ ] Periodic "synthesis" skill (weekly connections across notes)
- [ ] Integration with Obsidian Publish (public subset of vault)
- [ ] Conflict resolution heuristics (auto-resolve certain conflict types)
- [ ] Link suggestion (when writing a note, suggest relevant wikilinks)

## Contributing

This plugin is part of the `grokbot-plugins` monorepo:

```
grokbot-plugins/
├── second-brain/        # This plugin
├── ethereum-builder/    # Planned
├── creator-voice/       # Planned
└── skill-vetter/        # Planned
```

To contribute:
1. Fork the repo
2. Create a branch: `git checkout -b feature/your-feature`
3. Make changes, test thoroughly
4. Submit PR with description and test results

## License

MIT License — see [LICENSE](LICENSE)

## Author

Francesco Andreoli ([@francescoswiss](https://twitter.com/francescoswiss))

Built from a working 15-agent Obsidian vault deployed in production. Generalized for the Cursor/Grok Bot marketplace based on ClawHub demand analysis and marketplace gap research.

## Links

- [Grok Bot Marketplace](#) (TBD: marketplace listing)
- [ClawHub](https://clawhub.ai) (OpenClaw skill registry)
- [Obsidian](https://obsidian.md) (Note-taking app)
- [Karpathy LLM-wiki pattern](https://twitter.com/karpathy) (The mental model)

## Support

- GitHub Issues: [andreolf/grokbot-plugins](https://github.com/andreolf/grokbot-plugins/issues)
- Twitter: [@francescoswiss](https://twitter.com/francescoswiss)
