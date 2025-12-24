#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

source "$SCRIPT_DIR"/../core/constants.sh

func_profile_list() {
  for yaml_file in "$APP_PATH"/profiles/*.yaml; do
    [ -e "$yaml_file" ] || continue
    basename "$yaml_file" .yaml
  done
}

func_profile_info() {
  if [ -f "$APP_PATH"/profiles/"$1".yaml ]; then
    cat "$APP_PATH"/profiles/"$1".yaml
  else
    echo "Error: Profile '$1' not found."
    exit 1
  fi
}

func_profile_get() {
  yq -r '.profile' "$APP_PATH"/config/config.yaml
}

func_profile_set() {
  if [ -f "$APP_PATH"/profiles/"$1".yaml ]; then
    sudo yq -i ".profile = \"$1\"" "$APP_PATH"/config/config.yaml
    echo 'The profile will be applied on the first boot or after a reboot.'
  else
    echo "Error: Profile '$1' not found."
    exit 1
  fi
}

func_service_status() {
  systemctl status reprofed.service
}

func_service_enable() {
  sudo systemctl enable --force reprofed.service
}

func_service_disable() {
  sudo systemctl disable --force reprofed.service
}

func_updates_status() {
  yq -r '.updates' "$APP_PATH"/config/config.yaml
}

func_updates_enable() {
  sudo yq -i '.updates = true' "$APP_PATH"/config/config.yaml
}

func_updates_disable() {
  sudo yq -i '.updates = false' "$APP_PATH"/config/config.yaml
}

func_log() {
  if [ -f /var/log/"$APP_NAME".log ]; then
    cat /var/log/"$APP_NAME".log
  fi
}

func_version() {
  cat "$APP_PATH"/VERSION
  echo
}

func_help() {
  cat <<EOF
$APP_NAME - Declarative Fedora Configuration Manager

Usage:
  $APP_NAME [OPTION] [COMMAND] [ARGS]

Options:
EOF

  cat <<EOF | column -t -s $'\t'
  -p, --profile	Manage profiles (list | info <profile> | get | set <profile>)
  -s, --service	Control $APP_NAME service (status | enable | disable)
  -u, --updates	Manage automatic system updates (status | enable | disable)
  -l, --log	View $APP_NAME log
  -v, --version	Show version
  -h, --help	Show this help message
EOF

  cat <<EOF

Examples:
  $APP_NAME --profile list
  $APP_NAME -p set gnome
  $APP_NAME --service enable
  $APP_NAME -u disable
  $APP_NAME --log
EOF
}

func_error_args() {
  echo "Error: Invalid or missing arguments." >&2
  exit 1
}

func_main() {
  if [[ $# -eq 0 ]]; then
    func_help
    exit 0
  fi

  case "$1" in
    -p | --profile)
      case "${2-}" in
        list) [[ $# -eq 2 ]] && func_profile_list || func_error_args ;;
        info) [[ $# -eq 3 ]] && func_profile_info "$3" || func_error_args ;;
        get) [[ $# -eq 2 ]] && func_profile_get || func_error_args ;;
        set) [[ $# -eq 3 ]] && func_profile_set "$3" || func_error_args ;;
        *) func_error_args ;;
      esac
      ;;

    -s | --service)
      case "${2-}" in
        status) [[ $# -eq 2 ]] && func_service_status || func_error_args ;;
        enable) [[ $# -eq 2 ]] && func_service_enable || func_error_args ;;
        disable) [[ $# -eq 2 ]] && func_service_disable || func_error_args ;;
        *) func_error_args ;;
      esac
      ;;

    -u | --updates)
      case "${2-}" in
        status) [[ $# -eq 2 ]] && func_updates_status || func_error_args ;;
        enable) [[ $# -eq 2 ]] && func_updates_enable || func_error_args ;;
        disable) [[ $# -eq 2 ]] && func_updates_disable || func_error_args ;;
        *) func_error_args ;;
      esac
      ;;

    -l | --log) [[ $# -eq 1 ]] && func_log || func_error_args ;;

    -v | --version) [[ $# -eq 1 ]] && func_version || func_error_args ;;

    -h | --help) [[ $# -eq 1 ]] && func_help || func_error_args ;;

    *) func_error_args ;;
  esac
}

func_main "$@"
