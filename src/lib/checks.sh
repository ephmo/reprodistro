check_app_installed() {
  if [[ -x "${APP_BIN}" && -f "${APP_PREFIX}/${APP_ID}.sh" && -s "${APP_PREFIX}/VERSION" ]]; then
    return 0
  fi

  log_error "${APP_NAME} is not installed"
  return 1
}

check_arch() {
  local arch

  for arch in "${SUPPORTED_ARCHITECTURES[@]}"; do
    if [[ "${DISTRO_ARCH}" == "${arch}" ]]; then
      return 0
    fi
  done

  log_error "Unsupported architecture: ${DISTRO_ARCH}"
  log_info "Supported architectures: ${SUPPORTED_ARCHITECTURES[*]}"
  return 1
}

check_internet() {
  if ! ip route show default > /dev/null 2>&1; then
    log_error "No default network route found"
    return 1
  fi

  if ! getent hosts one.one.one.one > /dev/null 2>&1; then
    log_error "DNS resolution failed"
    return 1
  fi
}

check_root() {
  if [[ $EUID -ne 0 ]]; then
    log_error "Root privileges are required"
    return 1
  fi
}

check_supported_distro() {
  local distro

  for distro in "${SUPPORTED_DISTRIBUTIONS[@]}"; do
    if [[ "${DISTRO_ID}" == "${distro}" ]]; then
      return 0
    fi
  done

  log_error "Unsupported distribution: ${DISTRO_ID}"
  log_info "Supported distributions: ${SUPPORTED_DISTRIBUTIONS[*]}"
  return 1
}
