#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob

if ! command -v flatpak > /dev/null 2>&1; then
  dnf5 install -y flatpak
fi

flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
