#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob

echo "Checking for lines longer than 120 characters in .sh files..."

if grep -R -n --include='*.sh' $(grep -Ev '^\s*(#|$)' .bashignore | sed 's/^/--exclude-dir=/') '.\{121\}' .; then
  echo "❌ Found bash lines longer than 120 characters"
  exit 1
else
  echo "✅ No lines longer than 120 characters found"
fi
