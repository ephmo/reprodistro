#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob

if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root or with sudo."
  exit 1
fi
