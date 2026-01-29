core_update() {
  local current_version
  local latest_version
  local update_dir="${APP_PREFIX}/.update"

  log_info "Checking for ${APP_NAME} updates"

  current_version="$(app_version | tr -d '\n')"
  if [[ -z "${current_version}" ]]; then
    log_error "${APP_NAME} is not installed"
    return 1
  fi

  log_info "Installed version: ${current_version}"

  latest_version="$(curl -fsSL https://gitlab.com/ephmo/reprodistro/-/raw/main/src/VERSION | tr -d '\n')"
  if [[ -z "${latest_version}" ]]; then
    log_error "Failed to retrieve latest version information"
    return 1
  fi

  log_info "Available version: ${latest_version}"

  if [[ "${current_version}" == "${latest_version}" ]]; then
    log_ok "${APP_NAME} is already up to date"
    return 0
  fi

  log_info "Preparing update workspace"
  [[ -n "${update_dir:-}" ]] && rm -rf -- "${update_dir}"
  mkdir -p "${update_dir}"

  log_info "Downloading update package"

  if ! curl -fsSL \
    "https://gitlab.com/ephmo/reprodistro/-/archive/main/reprodistro-main.tar.gz" \
    | tar -xz -C "${update_dir}" --strip-components=1; then
    log_error "Failed to download or extract update package"
    return 1
  fi

  log_info "Applying update"
  if ! core_install; then
    log_error "Update process failed"
    return 1
  fi

  log_info "Cleaning up update workspace"
  [[ -n "${update_dir:-}" ]] && rm -rf -- "${update_dir}"

  log_ok "${APP_NAME} updated successfully to version ${latest_version}"
  return 0
}
