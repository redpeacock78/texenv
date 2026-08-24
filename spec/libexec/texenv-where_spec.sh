#shellcheck shell=bash
# Specs for current-version command lookup.

Describe 'texenv-where'
  where_before() {
    texenv_setup
    texenv_install_libexec texenv-where texenv-libs texenv-help
    texenv_make_version 2025.01
    set_global_version 2025.01
  }
  BeforeEach 'where_before'

  invoke() {
    "${TEXENV_SPEC_BIN}/texenv-where" "$@"
  }

  invoke_without_help() {
    PATH="${PATH#${TEXENV_SPEC_BIN}:}" "${TEXENV_SPEC_BIN}/texenv-where" "$@"
  }

  It 'prints a command path from the active version'
    setup_version_bin_command 2025.01 pdflatex
    When call invoke pdflatex
    The status should equal 0
    The line 1 of output should equal "${TEXENV_VERSIONS}/2025.01/bin/${TEXENV_PLATFORM}/pdflatex"
  End

  It 'reports when no version is selected'
    : > "${TEXENV_ROOT}/version"
    When call invoke pdflatex
    The status should equal 1
    The stderr should include 'no version set'
  End

  It 'reports a missing command argument'
    When call invoke
    The status should equal 1
    The stderr should include 'no command specified'
  End

  It 'reports a command absent from the active version'
    When call invoke missingcmd
    The status should equal 1
    The stderr should include "command 'missingcmd' not found in version '2025.01'"
  End

  It 'rejects a path traversal command name'
    When call invoke ../outside
    The status should equal 1
    The stderr should include 'invalid command identifier'
  End

  It 'execs help for -h'
    When call invoke -h
    The status should equal 0
    The output should include 'Usage: texenv where'
  End

  It 'execs help for --help'
    When call invoke --help
    The status should equal 0
    The output should include 'Usage: texenv where'
  End

  It 'fails clearly when a dependency is unavailable'
    When call invoke_without_help pdflatex
    The status should equal 1
    The stderr should include 'required component(s) missing'
  End

  It 'fails clearly when texenv-libs is unavailable'
    rm -f "${TEXENV_SPEC_BIN}/texenv-libs"
    When call invoke pdflatex
    The status should equal 1
    The stderr should include 'required component(s) missing'
  End

  It 'fails clearly when texenv-help is unavailable'
    rm -f "${TEXENV_SPEC_BIN}/texenv-help"
    When call invoke pdflatex
    The status should equal 1
    The stderr should include 'required component(s) missing'
  End
End
