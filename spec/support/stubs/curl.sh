#!/usr/bin/env bash
set -euo pipefail

OUT_FILE=""
PREVIOUS=""
for ARG in "${@}"; do
  [[ "${PREVIOUS}" == "-o" ]] && OUT_FILE="${ARG}"
  PREVIOUS="${ARG}"
done

if [[ "${*}" == *api.github.com* ]]; then
  builtin printf '  "tag_name": "v2025.01",\n'
elif [[ "${*}" == *-w* ]]; then
  builtin printf '200'
elif [[ -n "${OUT_FILE}" && "${OUT_FILE}" != /dev/null ]]; then
  cp "${TEXENV_CURL_FIXTURE:?}" "${OUT_FILE}"
fi
