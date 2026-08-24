#shellcheck shell=bash
# Specs for the root query command.

Describe 'texenv-root'
  root_before() {
    texenv_setup
    texenv_install_libexec texenv-root texenv-help
  }
  BeforeEach 'root_before'

  invoke() {
    "${TEXENV_SPEC_BIN}/texenv-root" "$@"
  }

  invoke_without_help() {
    PATH="${PATH#${TEXENV_SPEC_BIN}:}" "${TEXENV_SPEC_BIN}/texenv-root" "$@"
  }

  It 'prints the configured root path'
    When call invoke
    The status should equal 0
    The line 1 of output should equal "${TEXENV_ROOT}"
  End

  It 'execs help for -h'
    When call invoke -h
    The status should equal 0
    The output should include 'Usage: texenv root'
  End

  It 'execs help for --help'
    When call invoke --help
    The status should equal 0
    The output should include 'Usage: texenv root'
  End

  It 'reports an empty root'
    When call env TEXENV_ROOT= "${TEXENV_SPEC_BIN}/texenv-root"
    The status should equal 1
    The stderr should include 'TEXENV_ROOT is not set'
  End

  It 'fails clearly when help is unavailable'
    When call invoke_without_help
    The status should equal 1
    The stderr should include 'required component(s) missing'
  End
End
