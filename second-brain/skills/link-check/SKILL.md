---
name: link-check
description: Check for broken wikilinks, orphaned notes, and link graph integrity in the vault. Use periodically or before major changes to maintain vault health.
---

# Link Check

Verify wikilink integrity, find broken links, and identify orphaned notes. Maintains the vault's graph structure.

## Why link checking matters

The vault is a **linked graph** using `[[wikilinks]]`. Obsidian's graph view and backlinks depend on these links working. Broken links happen when:

1. **Files are renamed** without updating links
2. **Files are moved** without updating links
3. **Files are deleted** without removing links to them
4. **Typos** in link syntax
5. **Case mismatches** on case-sensitive filesystems

## Quick check

```bash
VAULT_PATH="${VAULT_PATH:-/vault}"
cd "$VAULT_PATH"

# Find all wikilinks in markdown files
grep -roh '\[\[.*\]\]' --include="*.md" . | \
  sed 's/\[\[\(.*\)\]\]/\1/' | \
  sort | uniq > /tmp/all-links.txt

# Find all markdown files
find . -name "*.md" -type f | \
  sed 's|^\./||; s|\.md$||' | \
  sort > /tmp/all-files.txt

# Compare: links that don't match files
comm -23 /tmp/all-links.txt /tmp/all-files.txt > /tmp/broken-links.txt

# Report
if [ -s /tmp/broken-links.txt ]; then
  echo "Broken links found:"
  cat /tmp/broken-links.txt
else
  echo "No broken links found."
fi
```

## Comprehensive link check script

Create this as a helper script or run inline:

```bash
#!/usr/bin/env bash
# vault-link-check.sh - Check for broken wikilinks and orphaned notes

set -euo pipefail

VAULT_PATH="${VAULT_PATH:-/vault}"
cd "$VAULT_PATH"

echo "=== Vault Link Check ==="
echo "Vault: $VAULT_PATH"
echo

# 1. Find all wikilinks
echo "Extracting all wikilinks..."
grep -roh '\[\[.*\]\]' --include="*.md" . 2>/dev/null | \
  sed 's/\[\[\([^|\]]*\).*/\1/' | \
  sort | uniq > /tmp/vault-links.txt

LINK_COUNT=$(wc -l < /tmp/vault-links.txt)
echo "Found $LINK_COUNT unique wikilinks"
echo

# 2. Find all markdown files (as link targets)
echo "Finding all markdown files..."
find . -name "*.md" -type f | \
  sed 's|^\./||; s|\.md$||' | \
  sort > /tmp/vault-files.txt

FILE_COUNT=$(wc -l < /tmp/vault-files.txt)
echo "Found $FILE_COUNT markdown files"
echo

# 3. Find broken links (links that don't match any file)
echo "Checking for broken links..."
comm -23 /tmp/vault-links.txt /tmp/vault-files.txt > /tmp/vault-broken.txt

BROKEN_COUNT=$(wc -l < /tmp/vault-broken.txt)
if [ "$BROKEN_COUNT" -gt 0 ]; then
  echo "⚠️  $BROKEN_COUNT broken links found:"
  cat /tmp/vault-broken.txt | head -20
  if [ "$BROKEN_COUNT" -gt 20 ]; then
    echo "... and $((BROKEN_COUNT - 20)) more"
  fi
  echo
else
  echo "✓ No broken links found"
  echo
fi

# 4. Find orphaned notes (files with no incoming links)
echo "Checking for orphaned notes..."
grep -rl '\[\[.*\]\]' --include="*.md" . 2>/dev/null | \
  sed 's|^\./||' | \
  while read -r file; do
    basename="${file%.md}"
    grep -rl "\[\[${basename}" --include="*.md" . 2>/dev/null
  done | sed 's|^\./||' | sort | uniq > /tmp/vault-linked-files.txt

comm -23 /tmp/vault-files.txt /tmp/vault-linked-files.txt > /tmp/vault-orphans.txt

ORPHAN_COUNT=$(wc -l < /tmp/vault-orphans.txt)
if [ "$ORPHAN_COUNT" -gt 0 ]; then
  echo "📝 $ORPHAN_COUNT potentially orphaned notes:"
  cat /tmp/vault-orphans.txt | head -20
  if [ "$ORPHAN_COUNT" -gt 20 ]; then
    echo "... and $((ORPHAN_COUNT - 20)) more"
  fi
  echo
else
  echo "✓ No orphaned notes found"
  echo
fi

# 5. Summary
echo "=== Summary ==="
echo "Total files: $FILE_COUNT"
echo "Total unique links: $LINK_COUNT"
echo "Broken links: $BROKEN_COUNT"
echo "Orphaned notes: $ORPHAN_COUNT"

# Exit with error if broken links found
if [ "$BROKEN_COUNT" -gt 0 ]; then
  exit 1
fi
```

## Understanding wikilink formats

Obsidian supports several wikilink formats:

```markdown
[[note-name]]                    # Basic link (basename only)
[[folder/note-name]]             # Path-based link
[[note-name|Display Text]]       # Link with display text
[[note-name#heading]]            # Link to heading
[[note-name#^block-id]]          # Link to block
```

The link check extracts the **target** (before `|`, `#`, or `^`):

```bash
# Extracts "note-name" from all these:
# [[note-name]]
# [[note-name|Display]]
# [[note-name#heading]]

sed 's/\[\[\([^|\]#^]*\).*/\1/'
```

## Common broken link causes

### 1. File renamed without updating links

**Symptom:** Link to old filename is broken.

**Fix:** Either:
- Rename file back and use `git mv` next time, OR
- Find and replace all links:

```bash
OLD_NAME="old-note-name"
NEW_NAME="new-note-name"

# Find all files linking to old name
grep -rl "\[\[${OLD_NAME}" --include="*.md" . 

# Replace in all files
find . -name "*.md" -exec sed -i "s/\[\[${OLD_NAME}/[[${NEW_NAME}/g" {} +

# Commit the fix
git add <affected-files>
git commit -m "agent-name: fix wikilinks after rename"
```

### 2. File moved without updating path links

**Symptom:** `[[folder/note]]` broken after moving `note.md`.

**Fix:** Update links to new path:

```bash
OLD_PATH="old-folder/note"
NEW_PATH="new-folder/note"

find . -name "*.md" -exec sed -i "s|\[\[${OLD_PATH}|[[${NEW_PATH}|g" {} +
```

### 3. Case mismatch

**Symptom:** `[[Note-Name]]` doesn't match `note-name.md`.

**Fix:** Links are case-sensitive on Linux/git but not on macOS/Windows. Use exact case:

```bash
# Find files with case-insensitive match
find . -iname "*note-name*"

# Update links to match actual filename
```

### 4. Link to deleted file

**Symptom:** Linked to a file that was archived or deleted.

**Fix:** Either:
- Restore the file, OR
- Remove the broken link, OR  
- Update link to point to archived location:

```markdown
# If file was moved to _archive/
[[_archive/old-folder/note-name]]
```

## Finding where a broken link is used

```bash
BROKEN_LINK="note-that-doesnt-exist"

echo "Files linking to [[$BROKEN_LINK]]:"
grep -rn "\[\[${BROKEN_LINK}" --include="*.md" .
```

This shows you every file and line number that uses the broken link.

## Orphaned notes

Orphaned notes have **no incoming links** (nothing links to them). They might be:

1. **Deliberate entry points** (index.md, AGENTS.md, READMEs)
2. **New notes** not yet linked
3. **Old notes** that should be linked or archived

### Review orphans

```bash
# List orphans
cat /tmp/vault-orphans.txt

# For each orphan, decide:
# - Link it from index.md or a relevant note
# - Archive it (move to _archive/)
# - Delete it (if truly not needed)
```

Orphans aren't necessarily problems, but reviewing them keeps the graph connected.

## Periodic maintenance

Run link check:

- **Before archiving files** — Ensure you're not breaking active links
- **After bulk renames/moves** — Verify all links updated
- **Weekly/monthly** — General health check
- **Before major refactoring** — Baseline check

## Integration with vault workflow

### During session start

Don't run link check on every session start (too slow). But if the vault has been heavily modified:

```bash
# After pulling
cd "$VAULT_PATH"
git log --oneline -20  # Check recent activity

# If many files renamed/moved/deleted, run link check
./scripts/vault-link-check.sh
```

### Before archiving

When moving files to `_archive/`:

```bash
FILE_TO_ARCHIVE="Notes/old-note.md"

# 1. Find who links to it
grep -rn "\[\[old-note" --include="*.md" .

# 2. Update those links to archived path or remove them
# [[old-note]] → [[_archive/Notes/old-note]] or remove

# 3. Move file
mkdir -p _archive/Notes
git mv "$FILE_TO_ARCHIVE" _archive/Notes/

# 4. Run link check
./scripts/vault-link-check.sh

# 5. Commit
git add <updated-linking-files> _archive/Notes/old-note.md
git commit -m "agent-name: archive old-note.md and update links"
```

## Fixing broken links in bulk

If link check finds many broken links:

```bash
# Save broken links to file
./scripts/vault-link-check.sh 2>&1 | grep "^\[\[" > broken-links.txt

# Review each broken link
while read -r broken; do
  echo "Broken link: $broken"
  
  # Find where it's used
  grep -rn "\[\[${broken}" --include="*.md" .
  
  # Decide: fix, remove, or archive
  read -p "Action (fix/remove/skip)? " action
  # Handle based on action
done < broken-links.txt
```

## Link check as a maintenance skill

Create a maintenance note when you run link checks:

```markdown
---
type: agent-output
agent: your-agent-name
created: YYYY-MM-DD
tags: [maintenance, links, vault-health]
---

# Link Check - YYYY-MM-DD

## Results

- Total files: 1,234
- Total links: 5,678
- Broken links: 3
- Orphaned notes: 12

## Broken Links Fixed

1. `[[old-project-name]]` → renamed to `[[new-project-name]]` in 5 files
2. `[[deleted-note]]` → link removed from 2 files  
3. `[[moved-note]]` → updated path to `[[new-folder/moved-note]]`

## Orphans Reviewed

- `index.md`, `AGENTS.md`, project READMEs → deliberate entry points, kept
- `old-capture.md` → archived to `_archive/Inbox/`
- 5 new notes in `Inbox/` → not yet processed, kept

## Actions Taken

- Fixed 3 broken links across 7 files
- Archived 1 orphaned note
- Vault graph is now clean

## Next Check

Recommended: YYYY-MM-DD (1 week) or after next bulk rename/move.
```

## Checklist

Before running link check:

- [ ] Vault is pulled and up to date
- [ ] You have time to fix issues found (don't start if you can't finish)

During link check:

- [ ] Run comprehensive check script
- [ ] Note broken link count and orphan count
- [ ] For each broken link: find where used, decide fix/remove/archive
- [ ] For orphans: review if they should be linked or archived

After fixing:

- [ ] Re-run link check to verify all fixed
- [ ] Commit fixes with clear message
- [ ] Document in maintenance log or your README
- [ ] Update index/log if you modified core notes

## Helper script location

Save the comprehensive check as:

```bash
VAULT_PATH="${VAULT_PATH:-/vault}"
mkdir -p "$VAULT_PATH/scripts"
cat > "$VAULT_PATH/scripts/vault-link-check.sh" << 'EOF'
#!/usr/bin/env bash
# (comprehensive script from above)
EOF
chmod +x "$VAULT_PATH/scripts/vault-link-check.sh"
```

Then run anytime:

```bash
cd "$VAULT_PATH"
./scripts/vault-link-check.sh
```
