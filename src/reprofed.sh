#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob

if [ "$EUID" -ne 0 ]; then
  echo "ERROR: This script must be run as root or with sudo."
  exit 1
fi

source /etc/os-release

distro_id="$ID"
distro_version_id="$VERSION_ID"

if [[ "$distro_id" != "fedora" ]]; then
  echo "ERROR: Unsupported distribution: $distro_id"
  exit 1
fi

if [[ "$TERM" != "linux" ]]; then
    echo "ERROR: This script must be run from a Linux virtual console (TTY)."
    echo
    echo "You are currently running in a graphical terminal."
    echo "Switch to a TTY using Ctrl+Alt+F3 (or F2–F6), then run the script again."
    exit 1
fi

systemctl isolate multi-user.target

func_profile_set() {
  if [ -f /opt/reprofed/profiles/"$1".yaml ]; then
    profile_file="/opt/reprofed/profiles/${1}.yaml"

    if ! DISTRO_VERSION_ID="$distro_version_id" \
      yq -e '.requires.distro_versions[] == strenv(DISTRO_VERSION_ID)' "$profile_file" > /dev/null 2>&1; then
      echo "ERROR: Fedora version ${DISTRO_VERSION_ID:-unknown} is not supported by the selected profile."
      exit 1
    fi

    if yq -e '.repos.rpmfusion-free == "true"' "$profile_file" > /dev/null 2>&1; then
      if ! dnf5 repo list --enabled | grep -q "^${rpmfusion-free}"; then
        dnf5 install -y \
          https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
      fi
    fi

    if yq -e '.repos.rpmfusion-nonfree == "true"' "$profile_file" > /dev/null 2>&1; then
      if ! dnf5 repo list --enabled | grep -q "^${rpmfusion-nonfree}"; then
        dnf5 install -y \
          https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
      fi
    fi

    if yq -e '.repos.vscode == "true"' "$profile_file" > /dev/null 2>&1; then
      if ! dnf5 repo list --enabled | grep -q "^${code}"; then
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

    if ! curl -s --head --connect-timeout 5 https://www.google.com > /dev/null; then
      echo "ERROR: No internet connection."
      exit 1
    fi

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

    packages_install_all_versions=$(yq -r '.packages.install.all_versions // [] | join(" ")' "$profile_file")

    packages_install_version_specific=$(DISTRO_ID="$distro_id" \
      yq -r '.packages.install["fedora_" + strenv(DISTRO_ID)] // [] | join(" ")' "$profile_file")

    rm -f /etc/dnf/protected.d/*

    if [[ -n "$installed_groups" ]]; then
      dnf5 mark user --skip-unavailable -y $installed_packages
      dnf5 group remove -y --exclude=dnf5,grub2-efi-x64,grub2-pc,shim-x64 $installed_groups
    fi

    dnf5 mark dependency --skip-unavailable -y $installed_packages

    if ! dnf5 install --allowerasing -y $minimal_packages; then
      echo "ERROR: Installation of minimal system packages failed."
      exit 1
    fi

    dnf5 mark user --skip-unavailable -y $minimal_packages
    dnf5 autoremove -y

    if ! dnf5 install -y $packages_install_all_versions $packages_install_version_specific; then
      echo "ERROR: Installation of selected profile packages failed."
      exit 1
    fi

    dnf5 autoremove -y
    dnf5 clean all

    echo "SUCCESS: Profile applied successfully."
    echo
    echo "The system will reboot automatically in 10 seconds."
    echo "Press Ctrl+C to cancel the reboot."
    echo

    sleep 9
    echo "Rebooting now..."
    sleep 1
    reboot
  else
    echo "ERROR: Profile '$1' not found."
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
  reprofed [OPTION] [COMMAND]

Options:
EOF

  cat << EOF | column -t -s $'\t'
  -p, --profile	Apply profile
  -v, --version	Show version
  -h, --help	Show this help message
EOF

  cat << EOF

Examples:
  reprofed -p gnome
  reprofed --profile kde
EOF
}

func_error_args() {
  echo "ERROR: Invalid or missing arguments." >&2
  exit 1
}

func_main() {
  if [[ $# -eq 0 ]]; then
    func_help
    exit 0
  fi

  case "$1" in
    -p | --profile)
      [[ $# -eq 2 ]] && func_profile_set "$2" || func_error_args
      ;;

    -v | --version) [[ $# -eq 1 ]] && func_version || func_error_args ;;

    -h | --help) [[ $# -eq 1 ]] && func_help || func_error_args ;;

    *) func_error_args ;;
  esac
}

func_main "$@"
