#!/usr/bin/env bash

declare -r TEXENV_DEBUG
[[ "${TEXENV_DEBUG}" == 1 ]] && set -x
set -euo pipefail

main() {
  declare -a ARGS
  case "${2:-}" in
    install | update | uninstall | remove | restore)
      ARGS=("${@:3}")
      for ARG in "${ARGS[@]}"; do
        [[ "${ARG}" == @(-h|--help|--version|--dry-run|--list|--json) ]] && return 0
      done
      "${TEXENV_BIN}/texenv" rehash
      "${TEXENV_BIN}/texenv" exec mktexlsr --verbose
      ;;
  esac
}

main "${@}"
