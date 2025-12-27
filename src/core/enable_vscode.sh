#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob

REPO_ID="code"
REPO_FILE="/etc/yum.repos.d/vscode.repo"

if ! dnf5 repo list --enabled | grep -q "^${REPO_ID}"; then
  rpm --import https://packages.microsoft.com/keys/microsoft.asc

  tee "$REPO_FILE" > /dev/null << EOF
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
fi
