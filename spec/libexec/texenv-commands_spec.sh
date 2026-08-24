#shellcheck shell=bash
# Specs for command discovery.

Describe 'texenv-commands'
  commands_before() {
    texenv_setup
    texenv_install_libexec texenv-commands texenv-help
    TEXENV_LIBEXEC="${SPEC_REPO_ROOT}/libexec"
    export TEXENV_LIBEXEC
  }
  BeforeEach 'commands_before'

  invoke() {
    "${TEXENV_SPEC_BIN}/texenv-commands" "$@"
  }

  invoke_without_help() {
    PATH="${PATH#${TEXENV_SPEC_BIN}:}" "${TEXENV_SPEC_BIN}/texenv-commands" "$@"
  }

  It 'lists commands from the libexec directory'
    When call invoke
    The status should equal 0
    The output should include 'commands'
    The output should include 'help'
    The output should not include 'libs'
  End

  It 'excludes help aliases from the command list'
    When call invoke
    The output should not include '-h'
    The output should not include '--help'
  End

  It 'sorts command names'
    command_fixture="${TEXENV_ROOT}/command-fixture"
    mkdir -p "${command_fixture}"
    : > "${command_fixture}/texenv-foo"
    : > "${command_fixture}/texenv-bar"
    TEXENV_LIBEXEC="${command_fixture}"
    export TEXENV_LIBEXEC
    When call invoke
    The status should equal 0
    The line 1 of output should equal 'bar'
    The line 2 of output should equal 'foo'
  End

  It 'execs help for -h'
    When call invoke -h
    The status should equal 0
    The output should include 'Usage: texenv commands'
  End

  It 'execs help for --help'
    When call invoke --help
    The status should equal 0
    The output should include 'Usage: texenv commands'
  End

  It 'fails clearly when help is unavailable'
    When call invoke_without_help
    The status should equal 1
    The stderr should include 'required component(s) missing'
  End
End
