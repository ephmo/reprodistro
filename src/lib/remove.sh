core_remove() {
  log_info "Removing ${APP_NAME}"

  rm -f "${APP_BIN}" || {
    log_error "Failed to remove binary"
    return 1
  }

  rm -rf -- "${APP_PREFIX}/" || {
    log_error "Failed to remove application files"
    return 1
  }

  log_ok "${APP_NAME} removed successfully"
  return 0
}
