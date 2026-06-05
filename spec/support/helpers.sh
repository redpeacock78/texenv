#shellcheck shell=bash
# Common test helpers shared across spec files.
# Sourced by spec_helper.sh.

# Usage: set_global_version <version_label>
# Writes the version label to ${TEXENV_ROOT}/${TEX_GLOBAL_VERSION_FILE}.
set_global_version() {
  : "${TEXENV_ROOT:?set_global_version: TEXENV_ROOT must be set}"
  : "${TEX_GLOBAL_VERSION_FILE:?set_global_version: TEX_GLOBAL_VERSION_FILE must be set}"
  echo "$1" > "${TEXENV_ROOT}/${TEX_GLOBAL_VERSION_FILE}"
}

# Usage: set_local_version <version_label>
# Writes the version label to ${TEXENV_DIR}/${TEX_LOCAL_VERSION_FILE}.
set_local_version() {
  : "${TEXENV_DIR:?set_local_version: TEXENV_DIR must be set}"
  : "${TEX_LOCAL_VERSION_FILE:?set_local_version: TEX_LOCAL_VERSION_FILE must be set}"
  echo "$1" > "${TEXENV_DIR}/${TEX_LOCAL_VERSION_FILE}"
}

# Usage: invoke_in_dir <executable_path> [args...]
# Runs the executable from inside ${TEXENV_DIR} in a subshell to avoid
# leaking the cwd change between examples.
invoke_in_dir() {
  : "${TEXENV_DIR:?invoke_in_dir: TEXENV_DIR must be set}"
  local exe="$1"; shift
  ( cd "${TEXENV_DIR}" && "${exe}" "$@" )
}

# Usage: setup_shim <command_name>
# Creates an executable empty file at ${TEXENV_SHIMS}/<command_name>.
setup_shim() {
  : "${TEXENV_SHIMS:?setup_shim: TEXENV_SHIMS must be set}"
  local name="$1"
  : > "${TEXENV_SHIMS}/${name}"
  chmod +x "${TEXENV_SHIMS}/${name}"
}

# Usage: setup_version_bin_command <version_label> <command_name>
# Creates an executable empty file at
# ${TEXENV_VERSIONS}/<version>/bin/${TEXENV_PLATFORM}/<command>.
setup_version_bin_command() {
  : "${TEXENV_VERSIONS:?setup_version_bin_command: TEXENV_VERSIONS must be set}"
  : "${TEXENV_PLATFORM:?setup_version_bin_command: TEXENV_PLATFORM must be set}"
  local ver="$1" cmd="$2"
  local bin_dir="${TEXENV_VERSIONS}/${ver}/bin/${TEXENV_PLATFORM}"
  mkdir -p "${bin_dir}"
  : > "${bin_dir}/${cmd}"
  chmod +x "${bin_dir}/${cmd}"
}
