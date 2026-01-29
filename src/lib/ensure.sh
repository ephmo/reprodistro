ensure_curl() {
  local pkg="curl"
  local cmd="${pkg}"
  local pkg_mgr
  local pkg_install_opts

  if command -v "${cmd}" > /dev/null 2>&1; then
    return 0
  fi

  case "$DISTRO_ID" in
    debian)
      pkg_mgr="apt-get"
      pkg_install_opts="install --no-install-recommends -y"
      ;;
    fedora)
      pkg_mgr="dnf5"
      pkg_install_opts="install -y"
      ;;
    *)
      log_error "Unsupported distribution: ${DISTRO_ID}"
      return 1
      ;;
  esac

  log_info "Installing dependency: ${pkg}"

  $pkg_mgr $pkg_install_opts "${pkg}" || {
    log_error "Failed to install '${pkg}'"
    return 1
  }

  log_ok "Dependency installed: ${pkg}"
}

ensure_go_yq() {
  local pkg="go-yq"
  local cmd="${pkg}"
  local platform

  if command -v "${cmd}" > /dev/null 2>&1; then
    return 0
  fi

  case "$DISTRO_ARCH" in
    x86_64) platform="linux_amd64" ;;
    *)
      log_error "Unsupported architecture: ${DISTRO_ARCH}"
      return 1
      ;;
  esac

  log_info "Installing dependency: ${pkg}"

  curl -fsSL \
    "https://github.com/mikefarah/yq/releases/latest/download/yq_${platform}" \
    -o "/usr/local/bin/${pkg}" || {
    log_error "Failed to download ${pkg}"
    return 1
  }

  chmod +x "/usr/local/bin/${pkg}"

  log_ok "Dependency installed: ${pkg}"
}
