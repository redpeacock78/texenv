#shellcheck shell=bash
# Spec for libexec/texenv---help.

Describe 'texenv---help'
  helpalias_before() {
    texenv_setup
    texenv_install_libexec texenv---help texenv-help
  }
  BeforeEach 'helpalias_before'

  invoke() {
    invoke_in_dir "${TEXENV_SPEC_BIN}/texenv---help" "$@"
  }

  It 'execs texenv-help and shows the global usage banner'
    When call invoke
    The status should equal 0
    The output should include 'USAGE: texenv <command>'
  End

  It 'errors when texenv-help is missing'
    rm -f "${TEXENV_SPEC_BIN}/texenv-help"
    When call invoke
    The status should equal 1
    The stderr should include 'help component(s) missing'
  End

  It 'produces no stderr on the happy path'
    When call invoke
    The status should equal 0
    The output should include 'USAGE: texenv'
    The stderr should equal ''
  End
End
