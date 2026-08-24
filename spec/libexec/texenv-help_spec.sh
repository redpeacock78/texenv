#shellcheck shell=bash
# Regression specs for static help dispatch and shell-evaluable help output.

Describe 'texenv-help'
  help_before() {
    texenv_setup
    texenv_install_libexec texenv-help
  }
  BeforeEach 'help_before'

  invoke_help() {
    "${TEXENV_SPEC_BIN}/texenv-help" "$@"
  }

  invoke_shell_help_syntax() {
    local output
    output="$(invoke_help shell)"
    printf '%s\n' "${output}" | bash -n
    printf 'syntax-ok\n'
  }

  It 'lists commands without dynamic function evaluation'
    When call invoke_help
    The output should include 'commands [options]'
    The output should include 'help'
  End

  It 'emits shell help that remains valid shell source'
    When call invoke_shell_help_syntax
    The status should equal 0
    The output should equal 'syntax-ok'
  End
End
