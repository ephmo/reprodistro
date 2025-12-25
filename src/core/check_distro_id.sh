#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob

check_distro_id() {
  DISTRO_ID=$(grep -E '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
  [[ "$DISTRO_ID" == "fedora" ]]
}
