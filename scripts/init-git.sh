#!/bin/bash
set -euo pipefail

echo "==> init-git.sh: initializing a fresh local git repository"

# if git is missing, just warn and exit successfully (we don't want to fail template generation)
if ! command -v git >/dev/null 2>&1; then
  echo "  [warning] git not found on PATH. Skipping git init."
  exit 0
fi

# init new repo
git init -b main >/dev/null 2>&1 || git init >/dev/null 2>&1
echo "  created new git repo (branch: main)"

# stage everything
git add -A

git rm -r --cached scripts

# try a commit; if it fails because user.name/user.email are missing, set local defaults and retry
if git commit -m "chore: initial commit from template" >/dev/null 2>&1; then
  echo "  initial commit created"
else
  echo "  initial commit failed — trying with local user.name/user.email"
  git config user.name "Template User"
  git config user.email "template@localhost"
  git commit -m "chore: initial commit from template" >/dev/null 2>&1 || {
    echo "  [warning] still unable to create commit; leaving repo uncommitted"
    exit 0
  }
  echo "  initial commit created with local user config"
fi

echo "==> git initialization complete"

rm -rf scripts
