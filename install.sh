#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

APP_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

source "$APP_DIR"/src/core/constants.sh
source "$APP_DIR"/src/core/check_root.sh
source "$APP_DIR"/src/core/check_distro_id.sh

if ! check_distro_id; then
  echo "Unsupported distribution: $DISTRO_ID"
  exit 1
fi

source "$APP_DIR"/src/core/check_distro_version.sh

if ! check_distro_version; then
  echo "Fedora version ${DISTRO_VERSION_ID:-unknown} is not supported."
  echo "Supported versions: ${SUPPORTED_VERSIONS[*]}"
  exit 1
fi

func_install() {
  if ! command -v yq > /dev/null 2>&1; then
    $DNF install -y yq
  fi

  install -d -m 755 "$APP_PATH"
  install -d -m 755 "$APP_PATH"/{bin,config,core,profiles}

  install -m 755 "$APP_DIR"/src/bin/*.sh "$APP_PATH"/bin/
  install -m 755 "$APP_DIR"/src/core/*.sh "$APP_PATH"/core/
  install -m 644 "$APP_DIR"/src/profiles/* "$APP_PATH"/profiles/
  install -m 644 -T "$APP_DIR"/src/VERSION "$APP_PATH"/VERSION

  if [ ! -f "$APP_PATH"/config/config.yaml ]; then
    install -m 644 -T "$APP_DIR"/src/config/config.yaml "$APP_PATH"/config/config.yaml
  fi

  install -m 644 -T "$APP_DIR"/src/systemd/reprofed.service /etc/systemd/system/reprofed.service

  ln -sf "$APP_PATH"/bin/reprofed-cli.sh /usr/bin/reprofed

  systemctl daemon-reload
  systemctl enable --force --quiet reprofed.service
}

func_remove() {
  systemctl disable --force --quiet --now reprofed.service 2> /dev/null
  rm -f /etc/systemd/system/reprofed.service
  systemctl daemon-reload
  rm -f /usr/bin/reprofed
  rm -rf "$APP_PATH"/
  rm -f /var/log/"$APP_NAME".log
}

func_help() {
  cat << EOF
Usage:
  $0 [OPTION]

Options:
EOF

  cat << EOF | column -t -s $'\t'
  -i, --install	Install the application
  -u, --update	Update the application
  -r, --remove	Remove the application
  -h, --help	Show this help message
EOF

  cat << EOF

Examples:
  $APP_NAME -i
  $APP_NAME --update
  $APP_NAME --remove
EOF
}

func_error_args() {
  echo "Error: Invalid argument." >&2
  exit 1
}

func_main() {
  if [[ $# -eq 0 ]]; then
    func_help
    exit 0
  fi

  case "$1" in
    -i | --install) [[ $# -eq 1 ]] && func_remove && func_install || func_error_args ;;

    -u | --update) [[ $# -eq 1 ]] && func_install || func_error_args ;;

    -r | --remove) [[ $# -eq 1 ]] && func_remove || func_error_args ;;

    -h | --help) [[ $# -eq 1 ]] && func_help || func_error_args ;;

    *) func_error_args ;;
  esac
}

func_main "$@"
