#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob

if [[ -t 1 ]] && [[ "${NO_COLOR:-}" != "1" ]]; then
  C_INFO=$'\033[1;34m'
  C_OK=$'\033[1;32m'
  C_WARN=$'\033[1;33m'
  C_ERROR=$'\033[1;31m'
  C_RESET=$'\033[0m'
else
  C_INFO=""
  C_OK=""
  C_WARN=""
  C_ERROR=""
  C_RESET=""
fi

log_info()  { echo "${C_INFO}[INFO]${C_RESET} $*"; }
log_ok()    { echo "${C_OK}[OK]${C_RESET} $*"; }
log_warn()  { echo "${C_WARN}[WARN]${C_RESET} $*"; }
log_error() { echo "${C_ERROR}[ERROR]${C_RESET} $*" >&2; }

check_root() {
  if [ "$EUID" -ne 0 ]; then
    log_error "This command requires root privileges."
    exit 1
  fi
}

script_path="$(readlink -f "${BASH_SOURCE[0]}")"
script_dir="$(dirname "$script_path")"

source /etc/os-release

distro_id="$ID"

if [[ "$distro_id" != "fedora" ]]; then
  log_error "Unsupported distribution: $distro_id"
  exit 1
fi

func_install() {
  check_root

  if ! command -v yq > /dev/null 2>&1; then
    log_info "Installing dependency: yq"
    dnf5 install -y yq
  fi

  install -d -m 755 /opt/reprofed
  install -d -m 755 /opt/reprofed/profiles

  install -m 644 "$script_dir"/src/profiles/* /opt/reprofed/profiles/
  install -m 755 -T "$script_dir"/src/reprofed.sh /opt/reprofed/reprofed.sh
  install -m 644 -T "$script_dir"/src/VERSION /opt/reprofed/VERSION

  ln -sf /opt/reprofed/reprofed.sh /usr/bin/reprofed
}

func_remove() {
  check_root

  rm -f /usr/bin/reprofed
  rm -rf /opt/reprofed/
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
  reprofed -i
  reprofed --update
  reprofed --remove
EOF
}

func_error_args() {
  log_error "Invalid argument."
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

log_ok "Installation completed successfully."
