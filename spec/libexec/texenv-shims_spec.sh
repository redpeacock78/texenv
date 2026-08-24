#shellcheck shell=bash
# Specs for the shim listing command.

Describe 'texenv-shims'
  shims_before() {
    texenv_setup
    texenv_install_libexec texenv-shims texenv-help
  }
  BeforeEach 'shims_before'

  invoke() {
    "${TEXENV_SPEC_BIN}/texenv-shims" "$@"
  }

  invoke_without_help() {
    PATH="${PATH#${TEXENV_SPEC_BIN}:}" "${TEXENV_SPEC_BIN}/texenv-shims" "$@"
  }

  It 'lists executable shims in sorted order'
    setup_shim bibtex
    setup_shim zzz
    setup_shim pdflatex
    setup_shim xelatex
    When call invoke
    The status should equal 0
    The line 1 of output should equal "${TEXENV_SHIMS}/bibtex"
    The line 2 of output should equal "${TEXENV_SHIMS}/pdflatex"
    The line 3 of output should equal "${TEXENV_SHIMS}/xelatex"
    The line 4 of output should equal "${TEXENV_SHIMS}/zzz"
  End

  It 'execs help for -h'
    When call invoke -h
    The status should equal 0
    The output should include 'Usage: texenv shims'
  End

  It 'execs help for --help'
    When call invoke --help
    The status should equal 0
    The output should include 'Usage: texenv shims'
  End

  It 'reports when no shims are generated'
    When call invoke
    The status should equal 1
    The stderr should include 'no shims generated'
  End

  It 'fails clearly when help is unavailable'
    When call invoke_without_help
    The status should equal 1
    The stderr should include 'required component(s) missing'
  End
End
