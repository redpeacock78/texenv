#shellcheck shell=bash
# Specs for version and per-version configuration removal.

Describe 'texenv-uninstall'
  uninstall_before() {
    texenv_setup
    texenv_install_libexec texenv-uninstall texenv-libs texenv-help
    mkdir -p "${TEXENV_VERSIONS}/2024.09" "${TEXENV_VERSIONS}/2025.01" \
      "${TEXENV_CONFIG}/2025.01"
    : > "${TEXENV_VERSIONS}/2025.01/sentinel"
    : > "${TEXENV_CONFIG}/2025.01/sentinel"
  }
  BeforeEach 'uninstall_before'

  invoke_uninstall() {
    "${TEXENV_SPEC_BIN}/texenv-uninstall" "$@"
  }

  uninstall_and_preserve_other_version() {
    invoke_uninstall 2025.01 > /dev/null \
      && test ! -e "${TEXENV_VERSIONS}/2025.01" \
      && test ! -e "${TEXENV_CONFIG}/2025.01" \
      && test -d "${TEXENV_VERSIONS}/2024.09"
  }

  It 'removes the selected version and its configuration'
    When call uninstall_and_preserve_other_version
    The status should equal 0
  End

  It 'rejects an uninstalled version'
    When call invoke_uninstall 2026.01
    The status should equal 1
    The stderr should include 'version 2026.01 is not installed'
  End

  It 'requires an initialized environment'
    TEXENV_CONFIG="${TEXENV_ROOT}/missing-config"
    export TEXENV_CONFIG
    When call invoke_uninstall 2025.01
    The status should equal 1
    The stderr should include "run 'texenv init' first"
  End

  It 'execs help for uninstall --help'
    When call invoke_uninstall --help
    The status should equal 0
    The output should include 'Usage: texenv uninstall'
  End
End
