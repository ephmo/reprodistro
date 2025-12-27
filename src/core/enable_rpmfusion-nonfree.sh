#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob

REPO_ID="rpmfusion-nonfree"

dnf5 config-manager setopt fedora-cisco-openh264.enabled=1

if ! dnf5 repo list --enabled | grep -q "^${REPO_ID}"; then
  dnf5 install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
fi
