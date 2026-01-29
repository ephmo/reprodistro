# Application identity
APP_ID="reprodistro"
APP_NAME="ReproDistro"

# Installation paths
APP_PREFIX="/opt/${APP_ID}"
APP_LIB_DIR="${APP_PREFIX}/lib"
APP_BUILTIN_PROFILES_DIR="${APP_PREFIX}/profiles/builtin"
APP_EXAMPLES_DIR="${APP_PREFIX}/profiles/examples"
APP_USER_PROFILES_DIR="/etc/${APP_ID}/profiles"
APP_VERSION_FILE="${APP_PREFIX}/VERSION"
APP_BIN="/usr/local/bin/${APP_ID}"

# Compatibility
SUPPORTED_DISTRIBUTIONS=(debian fedora)
SUPPORTED_ARCHITECTURES=(x86_64)
DISTRO_ARCH="$(uname -m)"
