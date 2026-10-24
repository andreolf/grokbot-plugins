---
name: vault-session-start
description: Pull the vault and read core protocol + notes at the start of every session and new task. Load this skill BEFORE any work in the vault to ensure you have the latest state and understand the rules.
---

# Vault Session Start

**When to use:** At the start of EVERY session that involves the vault, and at the start of every new task. This is the mandatory first step before reading or writing any vault content.

## 1. Pull the vault safely

```bash
VAULT_PATH="${VAULT_PATH:-/vault}"
cd "$VAULT_PATH"
git pull --rebase --autostash origin main
```

If `git pull --rebase` fails with "Cannot rebase onto multiple branches", another agent is pulling at the same moment. Wait 5-10 seconds and retry:

```bash
git fetch origin
git rebase origin/main
```

If rebase conflicts occur in files you don't own, abort and leave a note in `Inbox/` instead:

```bash
git rebase --abort
```

## 2. Read the protocol and core notes

After pulling successfully, read these files **in order**:

1. **`AGENTS.md`** — The master protocol. Every agent follows this file.
2. **`00-Core/Profile.md`** — User profile and context
3. **`00-Core/Preferences.md`** — User preferences and working style
4. **`00-Core/Active-Projects.md`** — Current active projects
5. **`Agents/<your-name>/README.md`** — Your own agent folder README (replace `<your-name>` with your agent identifier, e.g., `coding-bot`, `research-assistant`)

## 3. Task-specific reading

If the task involves the knowledge base (`Notes/`, `Ideas/`, `Projects/`), also read:

- **`index.md`** — The vault index with all registered notes
- **`log.md`** — Recent entries (newest at top) to understand recent work

## 4. Verify you're ready

Before proceeding with any vault work, confirm:

- [ ] Vault is pulled and up to date
- [ ] You've read `AGENTS.md` and understand your write scope
- [ ] You've read your own `Agents/<name>/README.md`
- [ ] You understand which folders you can write to
- [ ] For knowledge base work: you've read `index.md` and recent `log.md` entries

## Write scope reminder

From `AGENTS.md` § 2:

- Write **only** to your own `Agents/<name>/` folder, `Inbox/`, `Daily/`, or the shared knowledge base under the routing rules
- Edits to `00-Core/` go through a proposal in `Inbox/` unless explicitly asked
- Never edit or delete another agent's folder
- `raw/` is **read-only** for all agents
- Don't create new top-level folders without asking
- Don't delete files; archive instead
- Don't rename files unless explicitly asked (breaks wikilinks)

## Agent folder layout

```
Agents/<name>/
  README.md        # Role, rules, routines, notes log
  outputs/         # Dated outputs: YYYY-MM-DD-<type>-<slug>.md
  assets/          # Images/media: kebab-case, date-prefixed when dated
  data/            # CSV/JSON/TXT working data
  <working>.md     # Few standing working docs (optional)
```

## Example workflow

```bash
# 1. Pull
cd "${VAULT_PATH:-/vault}"
git pull --rebase --autostash origin main

# 2. Read protocol
cat AGENTS.md
cat 00-Core/Profile.md
cat 00-Core/Preferences.md
cat 00-Core/Active-Projects.md
cat Agents/coding-bot/README.md  # Replace with your agent name

# 3. For knowledge base tasks
cat index.md
head -50 log.md  # Recent entries
```

## Troubleshooting

**Pull fails repeatedly:** Check network connectivity. If origin is unreachable, work locally and sync when connection returns.

**Rebase conflicts in your own files:** Resolve them manually. This means you and another process modified the same file simultaneously.

**Rebase conflicts in files outside your scope:** Abort with `git rebase --abort`, then create a proposal in `Inbox/` explaining what you wanted to change.

**Missing protocol files:** If `AGENTS.md` or core files don't exist, the vault may not be initialized. Use the `bootstrap-vault` skill to set up a new vault.
