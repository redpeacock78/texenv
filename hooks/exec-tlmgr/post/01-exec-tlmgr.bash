#!/usr/bin/env bash

declare -r TEXENV_DEBUG
[[ "${TEXENV_DEBUG}" == 1 ]] && set -x
set -euo pipefail

main() {
  case "${2:-}" in
    install | update | uninstall | remove)
      texenv rehash > /dev/null
      type mktexlsr > /dev/null 2>&1 && {
        mktexlsr > /dev/null 2>&1 || true
      }
      ;;
  esac
}

main "${@}"
