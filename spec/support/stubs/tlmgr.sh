#shellcheck shell=bash
# tlmgr stub builder.

# Usage: mk_tlmgr_stub <bin_directory>
# Creates an executable tlmgr in <bin_directory> that reads its behavior
# from environment variables at invocation time:
#   TLMGR_VERSION_OUTPUT       — full string to print for `tlmgr --version`.
#   TLMGR_INSTALLED_FIXTURE    — path to a newline-separated list of installed package names,
#                                returned by `tlmgr info --only-installed --data name`.
#   TLMGR_FAIL_INFO             — make the installed-package query fail.
#   TLMGR_REPOSITORY_FILE       — file used to persist the repository between invocations.
#   TLMGR_FAIL_REPOSITORY       — make repository updates fail.
mk_tlmgr_stub() {
  local bin_dir="$1"
  local stub="${bin_dir}/tlmgr"
  cat > "${stub}" <<'STUB_EOF'
#!/usr/bin/env bash
set -euo pipefail
case "${1:-}" in
  --version)
    echo "${TLMGR_VERSION_OUTPUT:-tlmgr revision 12345 (TeX Live 2025)}"
    ;;
  info)
    shift
    if [[ "${1:-}" == "--only-installed" && "${2:-}" == "--data" && "${3:-}" == "name" ]]; then
      if [[ "${TLMGR_FAIL_INFO:-}" == 1 ]]; then
        echo "tlmgr stub: info failed" >&2
        exit 1
      fi
      if [[ -n "${TLMGR_INSTALLED_FIXTURE:-}" && -f "${TLMGR_INSTALLED_FIXTURE}" ]]; then
        cat "${TLMGR_INSTALLED_FIXTURE}"
      fi
    fi
    ;;
  option)
    if [[ "${2:-}" != "repository" ]]; then
      echo "tlmgr stub: unhandled option: $*" >&2
      exit 1
    fi
    if [[ -n "${3:-}" ]]; then
      if [[ "${TLMGR_FAIL_REPOSITORY:-}" == 1 ]]; then
        echo "tlmgr stub: repository update failed" >&2
        exit 1
      fi
      if [[ -n "${TLMGR_REPOSITORY_FILE:-}" ]]; then
        printf '%s\n' "${3}" > "${TLMGR_REPOSITORY_FILE}"
      fi
    else
      repository="${TLMGR_REPOSITORY:-https://ctan.example.invalid/tlnet}"
      if [[ -n "${TLMGR_REPOSITORY_FILE:-}" && -f "${TLMGR_REPOSITORY_FILE}" ]]; then
        repository="$(cat "${TLMGR_REPOSITORY_FILE}")"
      fi
      printf 'tlmgr: %s\n' "${repository}"
    fi
    ;;
  install)
    shift
    echo "installing: $*"
    ;;
  *)
    echo "tlmgr stub: unhandled: $*" >&2
    exit 1
    ;;
esac
STUB_EOF
  chmod +x "${stub}"
}
