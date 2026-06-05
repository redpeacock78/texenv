#shellcheck shell=bash
# Spec for libexec/texenv-where.

Describe 'texenv-where'
  where_before() {
    texenv_setup
    texenv_install_libexec texenv-where texenv-libs texenv-help
    texenv_make_version 2025.01
  }
  BeforeEach 'where_before'

  invoke() {
    invoke_in_dir "${TEXENV_SPEC_BIN}/texenv-where" "$@"
  }

  It 'prints the version bin path for an installed command'
    set_global_version 2025.01
    setup_version_bin_command 2025.01 pdflatex
    When call invoke pdflatex
    The status should equal 0
    The line 1 of output should equal "${TEXENV_VERSIONS}/2025.01/bin/${TEXENV_PLATFORM}/pdflatex"
  End

  It 'errors when no version is set'
    When call invoke pdflatex
    The status should equal 1
    The stderr should include 'no version set'
  End

  It 'errors when no command argument is given'
    set_global_version 2025.01
    When call invoke
    The status should equal 1
    The stderr should include 'no command specified'
  End

  It 'errors when the command is not in the version bin'
    set_global_version 2025.01
    When call invoke missing
    The status should equal 1
    The stderr should include "command 'missing' not found in version '2025.01'"
  End

  It 'execs texenv-help where when -h is given'
    When call invoke -h
    The status should equal 0
    The output should include 'Usage: texenv where'
  End

  It 'execs texenv-help where when --help is given'
    When call invoke --help
    The status should equal 0
    The output should include 'Usage: texenv where'
  End

  It 'errors when texenv-libs is missing'
    rm -f "${TEXENV_SPEC_BIN}/texenv-libs"
    When call invoke
    The status should equal 1
    The stderr should include 'required component(s) missing'
  End
End
