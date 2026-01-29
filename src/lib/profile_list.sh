core_profile_list() {
  local yaml_file
  local found=0

  if
    local files=("${APP_USER_PROFILES_DIR}"/*.yaml)
    ((${#files[@]} > 0))
  then
    log_info "User profiles:"
    for yaml_file in "${files[@]}"; do
      basename "${yaml_file}" .yaml
      found=1
    done
  fi

  if
    local files=("${APP_BUILTIN_PROFILES_DIR}"/*.yaml)
    ((${#files[@]} > 0))
  then
    log_info "Builtin profiles:"
    for yaml_file in "${files[@]}"; do
      basename "${yaml_file}" .yaml
      found=1
    done
  fi

  ((found == 0)) && log_warn "No profiles found"
}
