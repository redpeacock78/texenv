#shellcheck shell=bash
# Common test setup for all specs.
# Sourced by shellspec via --require directive.

# Determine repo root (one level up from spec/).
SPEC_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export SPEC_REPO_ROOT

# Source stub builders.
. "${SPEC_REPO_ROOT}/spec/support/stubs/tlmgr.sh"
. "${SPEC_REPO_ROOT}/spec/support/helpers.sh"

# Initialize a fresh texenv environment under the shellspec temporary base.
# Idempotent within a single Example: re-running clears state.
texenv_setup() {
  TEXENV_ROOT="${SHELLSPEC_TMPBASE}/texenv-${SHELLSPEC_EXAMPLE_ID:-default}"
  TEXENV_VERSIONS="${TEXENV_ROOT}/versions"
  TEXENV_CONFIG="${TEXENV_ROOT}/config"
  TEXENV_BIN="${TEXENV_ROOT}/bin"
  TEXENV_SHIMS="${TEXENV_ROOT}/shims"
  TEXENV_HOOKS="${TEXENV_ROOT}/hooks"
  TEXMF_HOME="${TEXENV_ROOT}/texmf"
  TEXENV_DIR="${TEXENV_ROOT}/work"
  TEXENV_VERSION=""
  TEX_GLOBAL_VERSION_FILE="version"
  TEX_LOCAL_VERSION_FILE=".tex-version"
  TEX_REQUIREMENTS_FILE="tex-require.txt"
  TEX_REQUIREMENTS_LOCK_FILE="tex-require.lock"
  TEX_CMD_LIST_CACHE="${TEXENV_CONFIG}/cmd_list_cache.txt"

  case "$(uname)" in
    Darwin) TEXENV_PLATFORM="universal-darwin" ;;
    Linux)
      case "$(uname -m)" in
        x86_64) TEXENV_PLATFORM="x86_64-linux" ;;
        aarch64|arm64) TEXENV_PLATFORM="aarch64-linux" ;;
        *) TEXENV_PLATFORM="x86_64-linux" ;;
      esac
      ;;
    *) TEXENV_PLATFORM="x86_64-linux" ;;
  esac

  export TEXENV_ROOT TEXENV_VERSIONS TEXENV_CONFIG TEXENV_BIN TEXENV_SHIMS
  export TEXENV_HOOKS TEXMF_HOME TEXENV_DIR TEXENV_VERSION TEXENV_PLATFORM
  export TEX_GLOBAL_VERSION_FILE TEX_LOCAL_VERSION_FILE
  export TEX_REQUIREMENTS_FILE TEX_REQUIREMENTS_LOCK_FILE
  export TEX_CMD_LIST_CACHE

  : "${SHELLSPEC_TMPBASE:?texenv_setup: SHELLSPEC_TMPBASE must be set by the shellspec runtime}"
  : "${TEXENV_ROOT:?texenv_setup: TEXENV_ROOT is empty, refusing to rm -rf}"
  rm -rf "${TEXENV_ROOT}"
  mkdir -p "${TEXENV_ROOT}" "${TEXENV_VERSIONS}" "${TEXENV_CONFIG}" \
    "${TEXENV_BIN}" "${TEXENV_SHIMS}" "${TEXENV_HOOKS}" "${TEXMF_HOME}" \
    "${TEXENV_DIR}"

  TEXENV_SPEC_BIN="${TEXENV_ROOT}/spec-bin"
  mkdir -p "${TEXENV_SPEC_BIN}"
  export TEXENV_SPEC_BIN

  PATH="${TEXENV_SPEC_BIN}:${PATH}"
  export PATH
}

# Copy named libexec scripts into the spec bin directory.
# Usage: texenv_install_libexec texenv-restore texenv-libs ...
texenv_install_libexec() {
  : "${TEXENV_SPEC_BIN:?texenv_install_libexec: call texenv_setup first}"
  local name
  for name in "$@"; do
    cp "${SPEC_REPO_ROOT}/libexec/${name}" "${TEXENV_SPEC_BIN}/${name}"
    chmod +x "${TEXENV_SPEC_BIN}/${name}"
  done
}

# Create a stub version directory containing a tlmgr stub whose behavior is
# configured at invocation time via TLMGR_VERSION_OUTPUT and TLMGR_INSTALLED_FIXTURE.
# Usage: texenv_make_version <version_label>
texenv_make_version() {
  local ver="$1"
  local bin="${TEXENV_VERSIONS}/${ver}/bin/${TEXENV_PLATFORM}"
  mkdir -p "${bin}"
  mk_tlmgr_stub "${bin}"
}
