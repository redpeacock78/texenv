#shellcheck shell=bash
# Specs for initialization and shell-scoped version output.

Describe 'texenv-init and texenv-shell'
  init_shell_before() {
    texenv_setup
    texenv_install_libexec texenv-init texenv-shell texenv-libs texenv-help
    texenv_make_version 2025.01
  }
  BeforeEach 'init_shell_before'

  invoke_init() {
    "${TEXENV_SPEC_BIN}/texenv-init" "$@"
  }

  invoke_shell() {
    "${TEXENV_SPEC_BIN}/texenv-shell" "$@"
  }

  check_init_source() {
    local output
    output="$(SHELL=/bin/zsh invoke_init -)"
    printf '%s\n' "${output}" | bash -n
    grep -qx 'export TEXENV_SHELL=zsh' <<< "${output}"
    printf '%s\n' syntax-ok
  }

  check_shell_source() {
    local output
    output="$(invoke_shell 2025.01)"
    printf '%s\n' "${output}" | bash -n
    printf '%s\n' syntax-ok
  }

  check_init_layout() {
    test -d "${fresh_root}/versions" \
      && test -d "${fresh_root}/config" \
      && test -d "${fresh_root}/shims" \
      && test -f "${fresh_root}/version"
  }

  initialize_and_check_layout() {
    invoke_init >/dev/null && check_init_layout
  }

  It 'creates the required directories and version file'
    fresh_root="${SHELLSPEC_TMPBASE}/fresh-root"
    TEXENV_ROOT="${fresh_root}"
    TEXENV_VERSIONS="${fresh_root}/versions"
    TEXENV_CONFIG="${fresh_root}/config"
    TEXENV_SHIMS="${fresh_root}/shims"
    TEXMF_HOME="${fresh_root}/texmf"
    export TEXENV_ROOT TEXENV_VERSIONS TEXENV_CONFIG TEXENV_SHIMS TEXMF_HOME
    When call initialize_and_check_layout
    The status should equal 0
  End

  It 'emits syntactically valid shell setup with the shell basename'
    When call check_init_source
    The status should equal 0
    The output should equal 'syntax-ok'
  End

  It 'execs help for init --help'
    When call invoke_init --help
    The status should equal 0
    The output should include 'Usage: texenv init'
  End

  It 'emits a valid shell source for an installed version'
    When call check_shell_source
    The status should equal 0
    The output should equal 'syntax-ok'
  End

  It 'rejects an uninstalled shell version'
    When call invoke_shell 2026.01
    The status should equal 1
    The output should include "version '2026.01' is not installed"
  End

  It 'rejects traversal in a shell version'
    When call invoke_shell ../outside
    The status should equal 1
    The output should include 'invalid version identifier'
  End

  It 'reports the configured shell version when no argument is given'
    TEXENV_VERSION=2025.01
    export TEXENV_VERSION
    When call invoke_shell
    The status should equal 0
    The output should include '2025.01'
  End

  It 'reports when no shell-specific version is configured'
    When call invoke_shell
    The status should equal 0
    The output should include 'no shell-specific version configured'
  End
End
