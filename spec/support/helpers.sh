#shellcheck shell=bash
# Common test helpers shared by libexec specs.

set_global_version() {
  : "${TEXENV_ROOT:?set_global_version: TEXENV_ROOT must be set}"
  : "${TEX_GLOBAL_VERSION_FILE:?set_global_version: version file must be set}"
  printf '%s\n' "$1" > "${TEXENV_ROOT}/${TEX_GLOBAL_VERSION_FILE}"
}

set_local_version() {
  : "${TEXENV_DIR:?set_local_version: TEXENV_DIR must be set}"
  : "${TEX_LOCAL_VERSION_FILE:?set_local_version: version file must be set}"
  printf '%s\n' "$1" > "${TEXENV_DIR}/${TEX_LOCAL_VERSION_FILE}"
}

invoke_in_dir() {
  : "${TEXENV_DIR:?invoke_in_dir: TEXENV_DIR must be set}"
  local executable="$1"
  shift
  (
    cd "${TEXENV_DIR}" || exit
    "${executable}" "${@}"
  )
}

setup_shim() {
  : "${TEXENV_SHIMS:?setup_shim: TEXENV_SHIMS must be set}"
  local name="$1"
  ln -s /bin/sh "${TEXENV_SHIMS}/${name}"
}

setup_version_bin_command() {
  : "${TEXENV_VERSIONS:?setup_version_bin_command: versions must be set}"
  : "${TEXENV_PLATFORM:?setup_version_bin_command: platform must be set}"
  local version="$1"
  local command_name="$2"
  local bin_dir="${TEXENV_VERSIONS}/${version}/bin/${TEXENV_PLATFORM}"
  mkdir -p "${bin_dir}"
  printf '%s\n' '#!/usr/bin/env bash' 'exit 0' > "${bin_dir}/${command_name}"
  chmod +x "${bin_dir}/${command_name}"
}
