#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

source "$SCRIPT_DIR"/../core/constants.sh

LOG_FILE="/var/log/$APP_NAME.log"

: > "$LOG_FILE"

msg_success() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') SUCCESS: $1" >> "$LOG_FILE"
}

msg_error() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR: $1" >> "$LOG_FILE"
}

source "$SCRIPT_DIR"/../core/check_distro_id.sh

if ! check_distro_id; then
  msg_error "Unsupported distribution."
  exit 1
fi

source "$SCRIPT_DIR"/../core/check_distro_version.sh

if ! check_distro_version; then
  msg_error "Fedora version ${DISTRO_VERSION_ID:-unknown} is not supported."
  exit 1
fi

PROFILE_NAME_VALUE=$(yq -r '.profile' "$APP_PATH"/config/config.yaml)

if [[ -z "$PROFILE_NAME_VALUE" ]]; then
  msg_error "Profile is not set."
  exit 1
fi

PROFILE_FILE="${APP_PATH}/profiles/${PROFILE_NAME_VALUE}.yaml"

if [ ! -f "$PROFILE_FILE" ]; then
  msg_error "Profile '$PROFILE_NAME_VALUE' not found."
  exit 1
fi

if ! DISTRO_VERSION_ID="$DISTRO_VERSION_ID" \
  yq -e '.requires.distro_versions[] == strenv(DISTRO_VERSION_ID)' "$PROFILE_FILE"; then
  msg_error "Fedora version ${DISTRO_VERSION_ID:-unknown} is not supported by the selected profile."
  exit 1
fi

if yq -e '.repos.rpmfusion.free == "true"' "$PROFILE_FILE"; then
  source "$SCRIPT_DIR"/../core/install_rpmfusion-free.sh
fi

if yq -e '.repos.rpmfusion.nonfree == "true"' "$PROFILE_FILE"; then
  source "$SCRIPT_DIR"/../core/install_rpmfusion-nonfree.sh
fi

if yq -e '.repos.flathub == "true"' "$PROFILE_FILE"; then
  source "$SCRIPT_DIR"/../core/install_flathub.sh
fi

if yq -e '.repos.vscode == "true"' "$PROFILE_FILE"; then
  source "$SCRIPT_DIR"/../core/install_vscode.sh
fi

if ! curl -s --head --connect-timeout 5 https://www.google.com > /dev/null; then
  msg_error "No internet connection."
  exit 1
fi
