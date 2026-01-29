core_install() {
  install -d -m 755 \
    "${APP_PREFIX}"/{lib,profiles/builtin,profiles/examples/{community,templates}}

  install -m 644 "${SCRIPT_DIR}/lib/"*.sh "${APP_PREFIX}/lib/"
  install -m 755 -T "${SCRIPT_DIR}/${APP_ID}.sh" "${APP_PREFIX}/${APP_ID}.sh"
  install -m 644 -T "${SCRIPT_DIR}/VERSION" "${APP_PREFIX}/VERSION"

  install -m 644 "${SCRIPT_DIR}/profiles/${DISTRO_ID}/${DISTRO_ARCH}/builtin/"*.yaml \
    "${APP_PREFIX}/profiles/builtin/" 2> /dev/null || true

  install -m 644 "${SCRIPT_DIR}/profiles/${DISTRO_ID}/${DISTRO_ARCH}/examples/community/"*.yaml \
    "${APP_PREFIX}/profiles/examples/community/" 2> /dev/null || true

  install -m 644 "${SCRIPT_DIR}/profiles/${DISTRO_ID}/${DISTRO_ARCH}/examples/templates/"*.yaml \
    "${APP_PREFIX}/profiles/examples/templates/" 2> /dev/null || true

  ln -sf "${APP_PREFIX}/${APP_ID}.sh" "${APP_BIN}"
}
