#!/usr/bin/env bash

declare -r TEXENV_DEBUG
[[ "${TEXENV_DEBUG}" == 1 ]] && set -x
set -euo pipefail

main() {
  declare -a ARGS
  case "${2:-}" in
    install | uninstall | remove | update | info | search)
      ARGS=("${@:3}")
      for ARG in "${ARGS[@]}"; do
        [[ "${ARG}" == @(-h|--help|--version) ]] && return 0
      done
      "${TEXENV_BIN}/texenv" repo
      ;;
  esac
}

main "${@}"
