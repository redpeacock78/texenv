#shellcheck shell=bash
# Spec for libexec/texenv-commands.

Describe 'texenv-commands'
  commands_before() {
    texenv_setup
    texenv_install_libexec texenv-commands texenv-help
    mkdir -p "${TEXENV_ROOT}/libexec"
    : > "${TEXENV_ROOT}/libexec/texenv-foo"
    : > "${TEXENV_ROOT}/libexec/texenv-bar"
    : > "${TEXENV_ROOT}/libexec/texenv-libs"
    : > "${TEXENV_ROOT}/libexec/texenv---help"
    : > "${TEXENV_ROOT}/libexec/texenv--h"
  }
  BeforeEach 'commands_before'

  invoke() {
    invoke_in_dir "${TEXENV_SPEC_BIN}/texenv-commands" "$@"
  }

  It 'lists subcommand names from libexec sorted'
    When call invoke
    The status should equal 0
    The line 1 of output should equal 'bar'
    The line 2 of output should equal 'foo'
  End

  It 'excludes alias scripts starting with a dash'
    When call invoke
    The status should equal 0
    The output should not include '-help'
    The output should not include '-h'
  End

  It 'excludes the libs helper'
    When call invoke
    The status should equal 0
    The output should not include 'libs'
  End

  It 'execs texenv-help commands when -h is given'
    When call invoke -h
    The status should equal 0
    The output should include 'Usage: texenv commands'
  End

  It 'execs texenv-help commands when --help is given'
    When call invoke --help
    The status should equal 0
    The output should include 'Usage: texenv commands'
  End

  It 'errors when texenv-help is missing'
    rm -f "${TEXENV_SPEC_BIN}/texenv-help"
    When call invoke
    The status should equal 1
    The stderr should include 'required component(s) missing'
  End
End
