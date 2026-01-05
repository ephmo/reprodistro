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

func_profile_list() {
  for yaml_file in /opt/reprofed/profiles/*.yaml; do
    [ -e "$yaml_file" ] || continue
    basename "$yaml_file" .yaml
  done
}

func_profile_apply() {
  log_info "Applying profile: $1"
  if [ "$EUID" -ne 0 ]; then
    log_error "This command requires root privileges."
    exit 1
  fi
  log_ok "Running with root privileges"

  source /etc/os-release

  log_ok "Detected OS: $ID $VERSION_ID"
  distro_id="$ID"
  distro_version_id="$VERSION_ID"

  if [[ "$distro_id" != "fedora" ]]; then
    log_error "Unsupported distribution: $distro_id"
    exit 1
  fi

  log_ok "Fedora Linux detected"

  if [[ "$TERM" != "linux" ]]; then
    log_error "This command must be run from a Linux virtual console (TTY)."
    echo
    echo "Use Ctrl+Alt+F3 (or F2–F6) to switch to a TTY and try again."
    exit 1
  fi
  log_ok "Running in Linux virtual console (TTY)"

  log_info "Switching system to multi-user (non-graphical) mode"
  systemctl isolate multi-user.target

  if [ -f /opt/reprofed/profiles/"$1".yaml ]; then
    profile_file="/opt/reprofed/profiles/${1}.yaml"
    log_ok "Profile file found: $profile_file"

    log_info "Validating profile compatibility"
    if ! DISTRO_ID="$distro_id" \
      yq -e '.requires.distro == strenv(DISTRO_ID)' "$profile_file" > /dev/null 2>&1; then
      log_error "This profile does not support Fedora Linux."
      exit 1
    fi
    log_ok "Profile supports Fedora Linux"

    if ! DISTRO_VERSION_ID="$distro_version_id" \
      yq -e '.requires.distro_versions[] == strenv(DISTRO_VERSION_ID)' "$profile_file" > /dev/null 2>&1; then
      log_error "This profile does not support this version of Fedora Linux."
      exit 1
    fi
    log_ok "Profile supports Fedora $VERSION_ID"

    distro_arch=$(uname -m)

    if ! DISTRO_ARCH="$distro_arch" \
      yq -e '.requires.arch == strenv(DISTRO_ARCH)' "$profile_file" > /dev/null 2>&1; then
      log_error "This profile does not support this architecture."
      exit 1
    fi
    log_ok "Profile supports architecture: $distro_arch"

    log_info "Configuring package repositories"
    if yq -e '.repos.rpmfusion-free == "true"' "$profile_file" > /dev/null 2>&1; then
      log_info "Ensuring RPM Fusion Free repository is enabled"
      if ! dnf5 repo list --enabled | grep -q -w "^rpmfusion-free"; then
        dnf5 install -y \
          https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
      fi
    fi

    if yq -e '.repos.rpmfusion-nonfree == "true"' "$profile_file" > /dev/null 2>&1; then
      log_info "Ensuring RPM Fusion Nonfree repository is enabled"
      if ! dnf5 repo list --enabled | grep -q -w "^rpmfusion-nonfree"; then
        dnf5 install -y \
          https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
      fi
    fi

    if yq -e '.repos.vscode == "true"' "$profile_file" > /dev/null 2>&1; then
      log_info "Ensuring Visual Studio Code repository is enabled"
      if ! dnf5 repo list --enabled | grep -q -w "^code"; then
        rpm --import https://packages.microsoft.com/keys/microsoft.asc

        tee /etc/yum.repos.d/vscode.repo > /dev/null << EOF
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
      fi
    fi

    copr_repos=$(yq -r '.repos.copr[]?' "$profile_file")

    if [[ -n "$copr_repos" ]]; then
      log_info "Ensuring COPR repositories are enabled"
      for copr_repo in $copr_repos; do
        dnf5 copr enable -y "$copr_repo"
      done
    fi

    log_info "Checking internet connectivity"
    if ! curl -s --head --connect-timeout 5 https://www.google.com > /dev/null; then
      log_error "No internet connection."
      exit 1
    fi
    log_ok "Internet connection available"

    log_info "Preparing package transaction"
    minimal_packages="@core \
	authselect \
	btrfs-progs \
	chrony \
	cryptsetup \
	dosfstools \
	efibootmgr \
	grub2-efi-x64 \
	grub2-pc 
	grub2-tools-extra \
	grubby \
	kernel \
	langpacks-en \
	lvm2 \
	shim-x64 \
	xfsprogs \
	yq"

    installed_packages=$(dnf5 repoquery --installed --queryformat="%{name} " --quiet)

    installed_groups=$(dnf5 group list --hidden --installed --quiet \
      | awk '$1 == "ID" { next } $1 == "Installed" { next } NF == 0 { next } { printf "%s ", $1 }')

    log_ok "Analyzed installed packages and groups"
    packages_install_all_versions=$(yq -r '.packages.install.all_versions // [] | join(" ")' "$profile_file")

    packages_install_version_specific=$(DISTRO_VERSION_ID="$distro_version_id" \
      yq -r '.packages.install["fedora_" + strenv(DISTRO_VERSION_ID)] // [] | join(" ")' "$profile_file")

    packages_exclude_all_versions=$(yq -r '.packages.exclude.all_versions // [] | join(",")' "$profile_file")

    packages_exclude_version_specific=$(DISTRO_VERSION_ID="$distro_version_id" \
      yq -r '.packages.exclude["fedora_" + strenv(DISTRO_VERSION_ID)] // [] | join(",")' "$profile_file")

    rm -f /etc/dnf/protected.d/*

    if [[ -n "$installed_groups" ]]; then
      log_info "Removing installed package groups"
      dnf5 mark user --skip-unavailable -y $installed_packages
      dnf5 group remove -y --exclude=dnf5,grub2-efi-x64,grub2-pc,shim-x64 $installed_groups
    fi

    log_info "Reclassifying installed packages as dependencies"
    dnf5 mark dependency --skip-unavailable -y $installed_packages

    log_info "Installing minimal Fedora base system"
    if ! dnf5 install --allowerasing -y $minimal_packages; then
      log_error "Installation of minimal system packages failed."
      exit 1
    fi
    log_ok "Minimal system packages installed"

    dnf5 mark user --skip-unavailable -y $minimal_packages

    log_info "Removing unneeded packages"
    dnf5 autoremove -y

    log_info "Installing profile-specific packages"
    if ! dnf5 install -y $packages_install_all_versions $packages_install_version_specific \
      --exclude=$packages_exclude_all_versions,$packages_exclude_version_specific; then
      log_error "Installation of selected profile packages failed."
      exit 1
    fi
    log_ok "Profile packages installed"

    dnf5 autoremove -y
    dnf5 clean all

    log_info "Applying service configuration"
    services_set_default=$(yq -r '.services.set-default // [] | join(" ")' "$profile_file")
    systemctl set-default --force $services_set_default

    services_enable=$(yq -r '.services.enable // [] | join(" ")' "$profile_file")
    systemctl enable --force $services_enable

    services_disable=$(yq -r '.services.disable // [] | join(" ")' "$profile_file")
    systemctl disable --force $services_disable

    services_mask=$(yq -r '.services.mask // [] | join(" ")' "$profile_file")
    systemctl mask --force $services_mask

    services_unmask=$(yq -r '.services.unmask // [] | join(" ")' "$profile_file")
    systemctl unmask --force $services_unmask

    log_ok "Profile application completed"
    echo
    echo "The system will reboot automatically in 10 seconds."
    echo "Press Ctrl+C to cancel the reboot."
    echo

    sleep 9
    echo "Rebooting now..."
    sleep 1
    reboot
  else
    log_error "Profile '$1' not found."
    exit 1
  fi
}

func_version() {
  cat /opt/reprofed/VERSION
}

func_help() {
  cat << EOF
ReproFed - Declarative Fedora Configuration Manager

Usage:
  reprofed [OPTIONS]
  reprofed --apply PROFILE

Options:
EOF

  cat << EOF | column -t -s $'\t'
  -l, --list	List all profiles
  -a, --apply	Apply a profile
  -v, --version	Show version
  -h, --help	Show this help message
EOF

  cat << EOF

Examples:
  reprofed --list
  sudo reprofed --apply gnome
EOF
}

func_error_args() {
  log_error "Invalid or missing arguments."
  exit 1
}

func_main() {
  if [[ $# -eq 0 ]]; then
    func_help
    exit 0
  fi

  case "$1" in
    -l | --list) [[ $# -eq 1 ]] && func_profile_list || func_error_args ;;

    -a | --apply) [[ $# -eq 2 ]] && func_profile_apply "$2" || func_error_args ;;

    -v | --version) [[ $# -eq 1 ]] && func_version || func_error_args ;;

    -h | --help) [[ $# -eq 1 ]] && func_help || func_error_args ;;

    *) func_error_args ;;
  esac
}

func_main "$@"
