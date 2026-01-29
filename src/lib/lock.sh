LOCK_FILE="/run/${APP_ID}.lock"
LOCK_FD=200

acquire_lock() {
  exec {LOCK_FD}> "$LOCK_FILE" || return 1

  if ! flock -n "$LOCK_FD"; then
    log_error "Another ${APP_NAME} operation is already running"
    return 1
  fi
}

release_lock() {
  flock -u "$LOCK_FD" || true
  rm -f "$LOCK_FILE" || true
}
