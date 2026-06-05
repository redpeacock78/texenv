#shellcheck shell=bash
# Spec for libexec/texenv-root.

Describe 'texenv-root'
  root_before() {
    texenv_setup
    texenv_install_libexec texenv-root texenv-help
  }
  BeforeEach 'root_before'

  invoke() {
    invoke_in_dir "${TEXENV_SPEC_BIN}/texenv-root" "$@"
  }

  It 'prints the TEXENV_ROOT path when set'
    When call invoke
    The status should equal 0
    The line 1 of output should equal "${TEXENV_ROOT}"
  End

  It 'execs texenv-help root when -h is given'
    When call invoke -h
    The status should equal 0
    The output should include 'Usage: texenv root'
  End

  It 'execs texenv-help root when --help is given'
    When call invoke --help
    The status should equal 0
    The output should include 'Usage: texenv root'
  End

  It 'errors when TEXENV_ROOT is empty'
    TEXENV_ROOT=""
    When call invoke
    The status should equal 1
    The stderr should include 'TEXENV_ROOT is not set'
  End

  It 'errors when texenv-help is missing'
    rm -f "${TEXENV_SPEC_BIN}/texenv-help"
    When call invoke
    The status should equal 1
    The stderr should include 'required component(s) missing'
  End
End
