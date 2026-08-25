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
    The output should include 'doctor [options]'
    The output should include 'Diagnose the TeX environment'
    The output should include 'help'
  End

  It 'describes doctor checks'
    When call invoke_help doctor
    The output should include 'Read-only checks include:'
    The output should include 'Perl and File::Find for tlmgr'
    The output should include 'package snapshot status'
  End

  It 'describes lock and archive options'
    When call invoke_help freeze
    The output should include 'tex-require.lock'
    The output should include 'SHA-512 checksums'
  End

  It 'describes restore validation options'
    When call invoke_help restore
    The output should include 'platform, repository, and package revisions'
    The output should include '--dry-run reports and validates'
  End

  It 'emits shell help that remains valid shell source'
    When call invoke_shell_help_syntax
    The status should equal 0
    The output should equal 'syntax-ok'
  End
End
