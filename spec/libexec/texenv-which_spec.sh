#shellcheck shell=bash
# Specs for shim path lookup.

Describe 'texenv-which'
  which_before() {
    texenv_setup
    texenv_install_libexec texenv-which texenv-libs texenv-help
  }
  BeforeEach 'which_before'

  invoke() {
    "${TEXENV_SPEC_BIN}/texenv-which" "$@"
  }

  invoke_without_help() {
    PATH="${PATH#${TEXENV_SPEC_BIN}:}" "${TEXENV_SPEC_BIN}/texenv-which" "$@"
  }

  It 'prints the path of an installed shim'
    setup_shim pdflatex
    When call invoke pdflatex
    The status should equal 0
    The line 1 of output should equal "${TEXENV_SHIMS}/pdflatex"
  End

  It 'rejects a path traversal command name'
    When call invoke ../outside
    The status should equal 1
    The stderr should include 'invalid command identifier'
  End

  It 'reports a missing command'
    When call invoke missingcmd
    The status should equal 1
    The stderr should include "command 'missingcmd' not found"
  End

  It 'reports a missing command argument'
    When call invoke
    The status should equal 1
    The stderr should include 'no command specified'
  End

  It 'execs help for -h'
    When call invoke -h
    The status should equal 0
    The output should include 'Usage: texenv which'
  End

  It 'execs help for --help'
    When call invoke --help
    The status should equal 0
    The output should include 'Usage: texenv which'
  End

  It 'fails clearly when help is unavailable'
    When call invoke_without_help missingcmd
    The status should equal 1
    The stderr should include 'required component(s) missing'
  End
End
