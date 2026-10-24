#!/usr/bin/env bash
# Sync the vault: stage ONLY the paths you list, commit, pull --rebase, push.
# Usage: vault-sync.sh "<agent-name>: <message>" <path> [<path> ...]
# Never stages everything: other agents write here concurrently.
set -euo pipefail

VAULT_PATH="${VAULT_PATH:-/vault}"
REMOTE="${VAULT_REMOTE:-origin}"
BRANCH="${VAULT_BRANCH:-main}"

cd "$VAULT_PATH" || exit 1

if [ $# -lt 2 ]; then
  echo "Usage: vault-sync.sh \"<agent-name>: <message>\" <path> [<path> ...]" >&2
  echo "List the files or your own folder to commit; never 'git add -A'" >&2
  exit 2
fi

MSG="$1"
shift

# Stage only the specified paths
git add -- "$@" || exit 1

# Check if there's anything to commit
if git diff --cached --quiet; then
  echo "Nothing to commit."
else
  git commit -m "$MSG" || exit 1
fi

# Verify remote exists
git remote get-url "$REMOTE" >/dev/null 2>&1 || {
  echo "No remote '$REMOTE'; skipping push."
  exit 0
}

# Pull with rebase, retry up to 3 times
for i in 1 2 3; do
  if git pull --rebase --autostash "$REMOTE" "$BRANCH"; then
    break
  fi
  echo "pull failed (attempt $i), retrying..." >&2
  sleep 5
  if [ $i = 3 ]; then
    echo "pull --rebase failed after 3 attempts; resolve manually (git rebase --abort to undo)" >&2
    exit 1
  fi
done

# Push to remote
git push || {
  echo "push failed" >&2
  exit 1
}
