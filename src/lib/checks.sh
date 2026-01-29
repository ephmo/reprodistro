check_app_installed() {
  log_info "Checking ${APP_NAME} installation"

  if [[ -x "${APP_BIN}" && -f "${APP_PREFIX}/${APP_ID}.sh" ]]; then
    log_ok "${APP_NAME} is installed"
    return 0
  fi

  log_error "${APP_NAME} is not installed"
  return 1
}

check_arch() {
  local arch

  log_info "Checking architecture support"

  for arch in "${SUPPORTED_ARCHITECTURES[@]}"; do
    if [[ "${DISTRO_ARCH}" == "${arch}" ]]; then
      log_ok "Supported architecture detected: ${DISTRO_ARCH}"
      return 0
    fi
  done

  log_error "Unsupported architecture: ${DISTRO_ARCH}"
  log_info "Supported architectures: ${SUPPORTED_ARCHITECTURES[*]}"
  return 1
}

check_internet() {
  log_info "Checking internet connectivity"

  if ! ip route show default > /dev/null 2>&1; then
    log_error "No default network route found"
    return 1
  fi

  if ! getent hosts one.one.one.one > /dev/null 2>&1; then
    log_error "DNS resolution failed"
    return 1
  fi

  log_ok "Internet connection is available"
  return 0
}

check_root() {
  log_info "Checking root privileges"

  if [[ $EUID -ne 0 ]]; then
    log_error "Root privileges are required"
    return 1
  fi

  log_ok "Root privileges confirmed"
  return 0
}

check_supported_distro() {
  local distro

  log_info "Checking distribution support"

  for distro in "${SUPPORTED_DISTRIBUTIONS[@]}"; do
    if [[ "${DISTRO_ID}" == "${distro}" ]]; then
      log_ok "Supported distribution detected: ${DISTRO_ID}"
      return 0
    fi
  done

  log_error "Unsupported distribution: ${DISTRO_ID}"
  log_info "Supported distributions: ${SUPPORTED_DISTRIBUTIONS[*]}"
  return 1
}
