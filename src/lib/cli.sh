core_app_help() {
  cat << EOF
${APP_NAME} - Declarative Linux System Configuration Manager

Usage:
  ${APP_ID} [OPTIONS]
  ${APP_ID} --apply PROFILE

Options:
  -i, --install Install the application
  -u, --update  Update the application
  -r, --remove  Remove the application
  -u, --update  Update ${APP_NAME}
  -l, --list    List all profiles
  -a, --apply   Apply a profile
  -h, --help    Show this help message
  -v, --version Show version

Examples:
  ${APP_ID} --list
  sudo ${APP_ID} --apply gnome
EOF
}

core_app_version() {
  cat "${APP_PREFIX}/VERSION"
}

core_error_args() {
  log_error "Invalid or missing arguments"
}
