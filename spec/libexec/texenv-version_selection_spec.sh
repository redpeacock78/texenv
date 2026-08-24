#shellcheck shell=bash
# Specs for version selection and resolution.

Describe 'version selection and resolution'
  version_selection_before() {
    texenv_setup
    texenv_install_libexec texenv-global texenv-local texenv-version texenv-versions texenv-libs texenv-help
    texenv_make_version 2024.09
    texenv_make_version 2025.01
  }
  BeforeEach 'version_selection_before'

  invoke_global() {
    "${TEXENV_SPEC_BIN}/texenv-global" "$@"
  }

  invoke_local() {
    "${TEXENV_SPEC_BIN}/texenv-local" "$@"
  }

  invoke_version() {
    "${TEXENV_SPEC_BIN}/texenv-version" "$@"
  }

  invoke_versions() {
    "${TEXENV_SPEC_BIN}/texenv-versions" "$@"
  }

  verify_global_roundtrip() {
    invoke_global 2025.01
    invoke_global
  }

  It 'sets and reads the global version'
    When call verify_global_roundtrip
    The status should equal 0
    The output should equal '2025.01'
  End

  It 'rejects an uninstalled global version'
    When call invoke_global 2026.01
    The status should equal 1
    The stderr should include 'version 2026.01 is not installed'
  End

  It 'rejects traversal in a local version'
    When call invoke_local ../outside
    The status should equal 1
    The stderr should include 'invalid version identifier'
  End

  It 'uses a local version over the global version'
    set_global_version 2024.09
    mkdir -p "${TEXENV_DIR}/project/child"
    printf '%s\n' 2025.01 > "${TEXENV_DIR}/project/.tex-version"
    TEXENV_DIR="${TEXENV_DIR}/project/child"
    export TEXENV_DIR
    When call invoke_version
    The status should equal 0
    The output should include '2025.01'
    The output should include '.tex-version'
  End

  It 'uses the shell environment version before filesystem resolution'
    set_global_version 2024.09
    TEXENV_VERSION=2025.01
    TEXENV_SHELL=zsh
    export TEXENV_VERSION TEXENV_SHELL
    When call invoke_version
    The status should equal 0
    The output should equal '2025.01 (set by zsh)'
  End

  It 'marks the active version when listing installed versions'
    set_global_version 2025.01
    When call invoke_versions
    The status should equal 0
    The output should include '* 2025.01 (set by'
    The output should include '  2024.09'
  End

  It 'reports when no global version is set'
    When call invoke_global
    The status should equal 1
    The stderr should include 'no version set'
  End

  It 'reports when no versions are installed'
    When call env TEXENV_VERSIONS="${TEXENV_ROOT}/missing" "${TEXENV_SPEC_BIN}/texenv-versions"
    The status should equal 1
    The stderr should include 'no versions installed'
  End
End
