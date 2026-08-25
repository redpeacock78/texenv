#shellcheck shell=bash
# tlmgr stub builder.

# Usage: mk_tlmgr_stub <bin_directory>
# Creates an executable tlmgr in <bin_directory> that reads its behavior
# from environment variables at invocation time:
#   TLMGR_VERSION_OUTPUT       — full string to print for `tlmgr --version`.
#   TLMGR_INSTALLED_FIXTURE    — path to a newline-separated list of installed package names,
#                                returned by `tlmgr info --only-installed --data name`.
#   TLMGR_INSTALLED_REVISION_FIXTURE — path to `name,localrev` rows for revision queries.
#   TLMGR_REMOTE_FIXTURE       — path to `name,remoterev` rows for remote queries.
#   TLMGR_FAIL_INFO             — make the installed-package query fail.
#   TLMGR_FAIL_OPTION           — make an option query or update fail.
#   TLMGR_FAIL_BACKUP           — make a package backup fail.
#   TLMGR_BACKUP_LOG            — file used to record backup calls.
#   TLMGR_RESTORE_LOG           — file used to record restore calls.
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
    if [[ "${1:-}" == "--only-installed" && "${2:-}" == "--data" && "${3:-}" == "name,localrev" ]]; then
      if [[ "${TLMGR_FAIL_INFO:-}" == 1 ]]; then
        echo "tlmgr stub: info failed" >&2
        exit 1
      fi
      if [[ -n "${TLMGR_INSTALLED_REVISION_FIXTURE:-}" && -f "${TLMGR_INSTALLED_REVISION_FIXTURE}" ]]; then
        cat "${TLMGR_INSTALLED_REVISION_FIXTURE}"
      elif [[ -n "${TLMGR_INSTALLED_FIXTURE:-}" && -f "${TLMGR_INSTALLED_FIXTURE}" ]]; then
        awk '{print $0 ",1"}' "${TLMGR_INSTALLED_FIXTURE}"
      fi
    elif [[ "${1:-}" == "--only-remote" && "${2:-}" == "--data" && "${3:-}" == "name,remoterev" ]]; then
      if [[ "${TLMGR_FAIL_INFO:-}" == 1 ]]; then
        echo "tlmgr stub: info failed" >&2
        exit 1
      fi
      if [[ -n "${TLMGR_REMOTE_FIXTURE:-}" && -f "${TLMGR_REMOTE_FIXTURE}" ]]; then
        cat "${TLMGR_REMOTE_FIXTURE}"
      elif [[ -n "${TLMGR_INSTALLED_REVISION_FIXTURE:-}" && -f "${TLMGR_INSTALLED_REVISION_FIXTURE}" ]]; then
        cat "${TLMGR_INSTALLED_REVISION_FIXTURE}"
      fi
    elif [[ "${1:-}" == "--only-installed" && "${2:-}" == "--data" && "${3:-}" == "name" ]]; then
      if [[ "${TLMGR_FAIL_INFO:-}" == 1 ]]; then
        echo "tlmgr stub: info failed" >&2
        exit 1
      fi
      if [[ -n "${TLMGR_INSTALLED_FIXTURE:-}" && -f "${TLMGR_INSTALLED_FIXTURE}" ]]; then
        cat "${TLMGR_INSTALLED_FIXTURE}"
      fi
    fi
    ;;
  check)
    shift
    if [[ "${1:-}" == all ]]; then
      if [[ "${TLMGR_FAIL_CHECK:-}" == 1 ]]; then
        echo "tlmgr stub: check failed" >&2
        exit 1
      fi
      printf '%s\n' "${TLMGR_CHECK_OUTPUT:-}"
    fi
    ;;
  option)
    if [[ "${2:-}" != "repository" ]]; then
      echo "tlmgr stub: unhandled option: $*" >&2
      exit 1
    fi
    if [[ "${TLMGR_FAIL_OPTION:-}" == 1 ]]; then
      echo "tlmgr stub: option failed" >&2
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
  backup)
    shift
    backup_dir=''
    while [[ "${1:-}" == --* ]]; do
      case "${1}" in
        --all)
          shift
          ;;
        --backupdir)
          backup_dir="${2:-}"
          shift 2
          ;;
        *)
          echo "tlmgr stub: unhandled backup option: ${1}" >&2
          exit 1
          ;;
      esac
    done
    if [[ "${TLMGR_FAIL_BACKUP:-}" == 1 ]]; then
      echo "tlmgr stub: backup failed" >&2
      exit 1
    fi
    [[ -n "${backup_dir}" ]] || exit 1
    mkdir -p "${backup_dir}"
    [[ -z "${TLMGR_BACKUP_LOG:-}" ]] || printf '%s\n' "${backup_dir}" > "${TLMGR_BACKUP_LOG}"
    if [[ -n "${TLMGR_INSTALLED_REVISION_FIXTURE:-}" && -f "${TLMGR_INSTALLED_REVISION_FIXTURE}" ]]; then
      while IFS=, read -r package revision; do
        printf 'archive:%s:%s\n' "${package}" "${revision}" > "${backup_dir}/${package}.r${revision}.tar.xz"
      done < "${TLMGR_INSTALLED_REVISION_FIXTURE}"
    fi
    ;;
  restore)
    shift
    dry_run=''
    backup_dir=''
    while [[ "${1:-}" == --* ]]; do
      case "${1}" in
        --dry-run)
          dry_run=1
          shift
          ;;
        --backupdir)
          backup_dir="${2:-}"
          shift 2
          ;;
        *)
          echo "tlmgr stub: unhandled restore option: ${1}" >&2
          exit 1
          ;;
      esac
    done
    package="${1:-}"
    revision="${2:-}"
    [[ -n "${package}" && -n "${revision}" && -n "${backup_dir}" ]] || exit 1
    [[ -f "${backup_dir}/${package}.r${revision}.tar.xz" ]] || {
      echo "tlmgr stub: backup not found" >&2
      exit 1
    }
    [[ -z "${TLMGR_RESTORE_LOG:-}" ]] || printf '%s\n' "${package},${revision},${dry_run:-restore}" > "${TLMGR_RESTORE_LOG}"
    if [[ -n "${dry_run}" ]]; then
      echo "dry-run: restoring: ${package} ${revision}"
    else
      if [[ -n "${TLMGR_INSTALLED_REVISION_FIXTURE:-}" ]]; then
        tmp="${TLMGR_INSTALLED_REVISION_FIXTURE}.tmp"
        awk -F, -v package="${package}" -v revision="${revision}" '$1 != package {print} END {print package "," revision}' "${TLMGR_INSTALLED_REVISION_FIXTURE}" > "${tmp}"
        mv "${tmp}" "${TLMGR_INSTALLED_REVISION_FIXTURE}"
      fi
      echo "restoring: ${package} ${revision}"
    fi
    ;;
  install)
    shift
    dry_run=''
    packages=()
    while [[ -n "${1:-}" ]]; do
      case "${1}" in
        --dry-run)
          dry_run=1
          ;;
        --no-depends-at-all)
          ;;
        *)
          packages+=("${1}")
          ;;
      esac
      shift
    done
    if [[ -n "${dry_run}" ]]; then
      [[ -z "${TLMGR_INSTALL_LOG:-}" ]] || printf '%s\n' dry-run > "${TLMGR_INSTALL_LOG}"
      echo "dry-run: installing: ${packages[*]}"
    else
      [[ -z "${TLMGR_INSTALL_LOG:-}" ]] || printf '%s\n' install > "${TLMGR_INSTALL_LOG}"
      if [[ -n "${TLMGR_INSTALLED_REVISION_FIXTURE:-}" && -f "${TLMGR_INSTALLED_REVISION_FIXTURE}" && -n "${TLMGR_REMOTE_FIXTURE:-}" && -f "${TLMGR_REMOTE_FIXTURE}" ]]; then
        for package in "${packages[@]}"; do
          revision="$(awk -F, -v package="${package}" '$1 == package {print $2; exit}' "${TLMGR_REMOTE_FIXTURE}")"
          [[ -n "${revision}" ]] || continue
          tmp="${TLMGR_INSTALLED_REVISION_FIXTURE}.tmp"
          awk -F, -v package="${package}" -v revision="${revision}" '$1 != package {print} END {print package "," revision}' "${TLMGR_INSTALLED_REVISION_FIXTURE}" > "${tmp}"
          mv "${tmp}" "${TLMGR_INSTALLED_REVISION_FIXTURE}"
        done
      fi
      echo "installing: ${packages[*]}"
    fi
    ;;
  *)
    echo "tlmgr stub: unhandled: $*" >&2
    exit 1
    ;;
esac
STUB_EOF
  chmod +x "${stub}"
}
