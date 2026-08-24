#shellcheck shell=bash
# Regression specs for shim/cache rebuilds.

Describe 'texenv-rehash'
  rehash_before() {
    texenv_setup
    texenv_install_libexec texenv-help texenv-libs texenv-rehash texenv-whence
    TEXENV_LIBEXEC="${SPEC_REPO_ROOT}/libexec"
    TEX_CMD_LIST_CACHE="${TEXENV_CONFIG}/cmd_list_cache.txt"
    export TEXENV_LIBEXEC TEX_CMD_LIST_CACHE
    texenv_make_version 2024.09
    texenv_make_version 2025.01
    for ver in 2024.09 2025.01; do
      printf '%s\n' '#!/usr/bin/env bash' 'exit 0' > "${TEXENV_VERSIONS}/${ver}/bin/${TEXENV_PLATFORM}/fakecmd"
      chmod +x "${TEXENV_VERSIONS}/${ver}/bin/${TEXENV_PLATFORM}/fakecmd"
    done
  }
  BeforeEach 'rehash_before'

  invoke_rehash() {
    "${TEXENV_SPEC_BIN}/texenv-rehash"
  }

  invoke_whence() {
    "${TEXENV_SPEC_BIN}/texenv-whence" "$@"
  }

  It 'caches full paths and reports every installed version'
    invoke_rehash
    When call invoke_whence fakecmd
    The status should equal 0
    The output should include '2024.09 =>'
    The output should include '2025.01 =>'
  End

  refresh_cache_for_repeated_command() {
    local path
    invoke_rehash > /dev/null
    texenv_make_version 2026.04
    path="${TEXENV_VERSIONS}/2026.04/bin/${TEXENV_PLATFORM}/fakecmd"
    printf '%s\n' '#!/usr/bin/env bash' 'exit 0' > "${path}"
    chmod +x "${path}"
    invoke_rehash > /dev/null
    grep -Fxq "${path}" "${TEX_CMD_LIST_CACHE}"
  }

  It 'refreshes the cache when a new version repeats a command name'
    When call refresh_cache_for_repeated_command
    The status should equal 0
  End

  verify_symlink_command() {
    local alias
    alias="${TEXENV_VERSIONS}/2024.09/bin/${TEXENV_PLATFORM}/fakealias"
    ln -s fakecmd "${alias}"
    invoke_rehash > /dev/null
    test -L "${TEXENV_SHIMS}/fakealias" || return 1
    grep -Fxq "${alias}" "${TEX_CMD_LIST_CACHE}"
  }

  It 'keeps executable symlink commands as separate shims'
    When call verify_symlink_command
    The status should equal 0
  End

  It 'clears shims successfully when no commands remain'
    invoke_rehash
    mv "${TEXENV_VERSIONS}/2024.09" "${SHELLSPEC_TMPBASE}/removed-2024.09"
    mv "${TEXENV_VERSIONS}/2025.01" "${SHELLSPEC_TMPBASE}/removed-2025.01"
    When call invoke_rehash
    The status should equal 0
    The output should not include 'no commands found'
    The path "${TEXENV_SHIMS}/fakecmd" should not be exist
  End

  It 'ignores stale paths in the command cache'
    invoke_rehash
    rm -rf "${TEXENV_VERSIONS}/2024.09"
    When call invoke_whence fakecmd
    The status should equal 0
    The output should not include '2024.09 =>'
    The output should include '2025.01 =>'
  End
End
