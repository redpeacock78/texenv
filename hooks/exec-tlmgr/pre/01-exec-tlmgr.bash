#!/usr/bin/env bash

declare -r TEXENV_DEBUG
[[ "${TEXENV_DEBUG}" == 1 ]] && set -x
set -euo pipefail

main() {
  case "${2:-}" in
    install | uninstall | remove | update | info | search)
      texenv repo > /dev/null
      ;;
  esac
}

main "${@}"
