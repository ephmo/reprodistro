#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob

check_distro_version() {
  DISTRO_VERSION_ID=$(grep -E '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
  SUPPORTED_VERSIONS=(42 43)
  [[ "${SUPPORTED_VERSIONS[*]}" =~ (^|[[:space:]])"${DISTRO_VERSION_ID}"([[:space:]]|$) ]]
}
