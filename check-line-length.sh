#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob

source ./src/lib/logging.sh

log_info "Checking for lines longer than 120 characters in .sh files..."

if grep -R -n --include='*.sh' $(grep -Ev '^\s*(#|$)' .bashignore | sed 's/^/--exclude-dir=/') '.\{121\}' .; then
  log_error "Found bash lines longer than 120 characters"
  exit 1
else
  log_ok "No lines longer than 120 characters found"
fi
