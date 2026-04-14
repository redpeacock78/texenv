#!/usr/bin/env bash

declare -r TEXENV_DEBUG
[[ "${TEXENV_DEBUG}" == 1 ]] && set -x
set -euo pipefail

main() {
  case "${2:-}" in
    install | update | uninstall | remove)
      if [[ ! "${*:3}" =~ (--dry-run|--list) ]]; then
        "${TEXENV_BIN}/texenv" rehash
        "${TEXENV_BIN}/texenv" exec mktexlsr --verbose
      fi
      ;;
  esac
}

main "${@}"
