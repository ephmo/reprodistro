#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob

DISTRO_ID=$(grep -E '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
DISTRO_VERSION_ID=$(grep -E '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
SUPPORTED_VERSIONS=(42 43)

if [[ "$DISTRO_ID" != "fedora" ]]; then
  echo "Unsupported distribution: $DISTRO_ID"
  exit 1
fi

if [[ ! "${SUPPORTED_VERSIONS[*]}" =~ (^|[[:space:]])"${DISTRO_VERSION_ID}"([[:space:]]|$) ]]; then
  echo "Fedora version ${DISTRO_VERSION_ID:-unknown} is not supported."
  echo "Supported versions: ${SUPPORTED_VERSIONS[*]}"
  exit 1
fi
