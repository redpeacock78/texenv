#shellcheck shell=bash
# Spec for libexec/texenv-which.

Describe 'texenv-which'
  which_before() {
    texenv_setup
    texenv_install_libexec texenv-which texenv-help
  }
  BeforeEach 'which_before'

  invoke() {
    invoke_in_dir "${TEXENV_SPEC_BIN}/texenv-which" "$@"
  }

  It 'prints the shim path for an installed command'
    setup_shim pdflatex
    When call invoke pdflatex
    The status should equal 0
    The line 1 of output should equal "${TEXENV_SHIMS}/pdflatex"
  End

  It 'errors when no command argument is given'
    When call invoke
    The status should equal 1
    The stderr should include 'no command specified'
  End

  It 'errors when the shim does not exist'
    When call invoke missing
    The status should equal 1
    The stderr should include "command 'missing' not found"
  End

  It 'execs texenv-help which when -h is given'
    When call invoke -h
    The status should equal 0
    The output should include 'Usage: texenv which'
  End

  It 'execs texenv-help which when --help is given'
    When call invoke --help
    The status should equal 0
    The output should include 'Usage: texenv which'
  End

  It 'errors when texenv-help is missing'
    rm -f "${TEXENV_SPEC_BIN}/texenv-help"
    When call invoke
    The status should equal 1
    The stderr should include 'required component(s) missing'
  End
End
