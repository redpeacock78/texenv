#!/usr/bin/env bash

declare -r TEXENV_DEBUG
[[ "${TEXENV_DEBUG}" == 1 ]] && set -x
set -euo pipefail

main() {
  case "${2:-}" in
    install | update | uninstall | remove)
      "${TEXENV_BIN}/texenv" rehash
      "${TEXENV_BIN}/texenv" exec mktexlsr --verbose
      ;;
  esac
}

main "${@}"
