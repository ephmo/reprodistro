#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd -- "$(dirname -- "$SCRIPT_PATH")" && pwd)"

source /etc/os-release

source "$SCRIPT_DIR"/lib/constants.sh
source "$SCRIPT_DIR"/lib/logging.sh
source "$SCRIPT_DIR"/lib/lock.sh

source "$SCRIPT_DIR"/lib/checks.sh
source "$SCRIPT_DIR"/lib/ensure.sh

source "$SCRIPT_DIR"/lib/install.sh
source "$SCRIPT_DIR"/lib/update.sh
source "$SCRIPT_DIR"/lib/remove.sh

source "$SCRIPT_DIR"/lib/profile_list.sh
source "$SCRIPT_DIR"/lib/profile_checks.sh
source "$SCRIPT_DIR"/lib/profile_apply.sh

source "$SCRIPT_DIR"/lib/cli.sh

DISTRO_ID="$ID"
DISTRO_VERSION_ID="$VERSION_ID"

app_install() {
  check_root || exit 1
  check_supported_distro || exit 1
  check_arch || exit 1
  acquire_lock || exit 1
  trap release_lock EXIT INT TERM
  check_internet || exit 1
  ensure_curl || exit 1
  ensure_go_yq || exit 1
  log_info "Installing ${APP_NAME}"
  core_install || exit 1
  log_ok "${APP_NAME} installed successfully"
  log_info "Binary: ${APP_BIN}"
  log_info "Builtin profiles: ${APP_BUILTIN_PROFILES_DIR}/"
  log_info "Example profiles (not applied directly): ${APP_EXAMPLES_DIR}/"
  log_info "To customize, copy profiles to: ${APP_USER_PROFILES_DIR}/"
}

app_update() {
  check_root || exit 1
  check_app_installed || exit 1
  check_supported_distro || exit 1
  check_arch || exit 1
  acquire_lock || exit 1
  trap release_lock EXIT INT TERM
  check_internet || exit 1
  ensure_curl || exit 1
  core_update || exit 1
}

app_remove() {
  check_root || exit 1
  check_app_installed || exit 1
  acquire_lock || exit 1
  trap release_lock EXIT INT TERM
  core_remove || exit 1
}

profile_list() {
  check_app_installed || exit 1
  core_profile_list || exit 1
}

profile_apply() {
  check_root || exit 1
  check_app_installed || exit 1
  check_supported_distro || exit 1
  check_arch || exit 1
  acquire_lock || exit 1
  trap release_lock EXIT INT TERM
  check_internet || exit 1
  ensure_go_yq || exit 1
  core_profile_apply || exit 1
}

app_help() {
  core_app_help || exit 1
}

app_version() {
  core_app_version || exit 1
}

error_args() {
  core_error_args
  exit 1
}

app_cli() {
  if [[ $# -eq 0 ]]; then
    app_help
    exit 0
  fi

  case "$1" in
    -i | --install) [[ $# -eq 1 ]] && app_install || error_args ;;
    -u | --update) [[ $# -eq 1 ]] && app_update || error_args ;;
    -r | --remove) [[ $# -eq 1 ]] && app_remove || error_args ;;
    -l | --list) [[ $# -eq 1 ]] && profile_list || error_args ;;
    -a | --apply) [[ $# -eq 2 ]] && profile_apply "$2" || error_args ;;
    -h | --help) [[ $# -eq 1 ]] && app_help || error_args ;;
    -v | --version) [[ $# -eq 1 ]] && app_version || error_args ;;
    *) error_args ;;
  esac
}

app_cli "$@"
