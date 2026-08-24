#shellcheck shell=bash
# Specs for environment diagnostics and fallback values.

Describe 'texenv-env'
  env_before() {
    texenv_setup
    texenv_install_libexec texenv-env texenv-libs texenv-help texenv-repo texenv-version texenv-versions
    texenv_make_version 2025.01
    set_global_version 2025.01
    TLMGR_REPOSITORY_FILE="${TEXENV_ROOT}/tlmgr-repository"
    export TLMGR_REPOSITORY_FILE
  }
  BeforeEach 'env_before'

  invoke_env() {
    "${TEXENV_SPEC_BIN}/texenv-env" "$@"
  }

  make_kpsewhich() {
    local mode="$1"
    local kpsewhich="${TEXENV_VERSIONS}/2025.01/bin/${TEXENV_PLATFORM}/kpsewhich"
    if [[ "${mode}" == failure ]]; then
      printf '%s\n' '#!/usr/bin/env bash' 'exit 1' > "${kpsewhich}"
    else
      printf '%s\n' '#!/usr/bin/env bash' "printf '%s\\n' kpse-result" > "${kpsewhich}"
    fi
    chmod +x "${kpsewhich}"
  }

  It 'reports active version, repository, and kpsewhich paths'
    make_kpsewhich success
    printf '%s\n' https://mirror.example.test/tlnet > "${TLMGR_REPOSITORY_FILE}"
    When call invoke_env
    The status should equal 0
    The output should include 'TinyTeX: 2025.01'
    The output should include 'TEXHOME        = kpse-result'
    The output should include 'https://mirror.example.test/tlnet'
    The output should include '* 2025.01'
  End

  It 'falls back when kpsewhich is unavailable'
    make_kpsewhich failure
    When call invoke_env
    The status should equal 0
    The output should include "TEXHOME        = ${TEXMF_HOME}"
    The output should include 'TEXMFVAR       = not set'
  End

  It 'execs help for env --help'
    When call invoke_env --help
    The status should equal 0
    The output should include 'Usage: texenv env'
  End
End
