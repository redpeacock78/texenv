#shellcheck shell=bash
# Specs for the short help alias command.

Describe 'texenv--h'
  short_help_before() {
    texenv_setup
    texenv_install_libexec texenv--h texenv-help
  }
  BeforeEach 'short_help_before'

  invoke() {
    "${TEXENV_SPEC_BIN}/texenv--h" "$@"
  }

  invoke_without_help() {
    PATH="${PATH#${TEXENV_SPEC_BIN}:}" "${TEXENV_SPEC_BIN}/texenv--h" "$@"
  }

  It 'execs the main help command'
    When call invoke
    The status should equal 0
    The output should include 'USAGE: texenv <command>'
    The stderr should equal ''
  End

  It 'ignores extra arguments like the alias implementation'
    When call invoke ignored
    The status should equal 0
    The output should include 'USAGE: texenv <command>'
    The stderr should equal ''
  End

  It 'reports when help is unavailable'
    When call invoke_without_help
    The status should equal 1
    The stderr should include 'help component(s) missing'
  End
End
