#shellcheck shell=bash
# Regression specs for version identifiers used in filesystem paths.

Describe 'version identifier validation'
  version_validation_before() {
    texenv_setup
    texenv_install_libexec texenv-global texenv-help texenv-libs texenv-uninstall
    mkdir -p "${TEXENV_VERSIONS}/2025.01" "${TEXENV_ROOT}/outside"
    : > "${TEXENV_ROOT}/outside/sentinel"
  }
  BeforeEach 'version_validation_before'

  invoke_global_traversal() {
    local status
    if "${TEXENV_SPEC_BIN}/texenv-global" ../outside; then
      status=0
    else
      status=$?
    fi
    test ! -e "${TEXENV_ROOT}/version" || return 2
    return "${status}"
  }

  invoke_uninstall_traversal() {
    local status
    if "${TEXENV_SPEC_BIN}/texenv-uninstall" ../outside; then
      status=0
    else
      status=$?
    fi
    test -e "${TEXENV_ROOT}/outside/sentinel" || return 2
    return "${status}"
  }

  It 'rejects path traversal before writing a global version'
    When call invoke_global_traversal
    The status should equal 1
    The stderr should include 'invalid version identifier'
  End

  It 'rejects path traversal before uninstalling'
    When call invoke_uninstall_traversal
    The status should equal 1
    The stderr should include 'invalid version identifier'
  End

  It 'accepts a normal release version'
    When call "${TEXENV_SPEC_BIN}/texenv-global" 2025.01
    The status should equal 0
  End
End
