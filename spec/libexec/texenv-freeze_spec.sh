#shellcheck shell=bash
# Specs for atomic requirements snapshots.

Describe 'texenv-freeze'
  freeze_before() {
    texenv_setup
    texenv_install_libexec texenv-freeze texenv-exec texenv-version texenv-libs texenv-help
    texenv_make_version 2025.01
    set_global_version 2025.01
    TEXENV_INSTALLED_FIXTURE="${TEXENV_ROOT}/installed.txt"
    printf '%s\n' collection-basic geometry latex-bin > "${TEXENV_INSTALLED_FIXTURE}"
    export TEXENV_INSTALLED_FIXTURE
    TLMGR_INSTALLED_FIXTURE="${TEXENV_INSTALLED_FIXTURE}"
    TLMGR_INSTALLED_REVISION_FIXTURE="${TEXENV_ROOT}/installed-revisions.txt"
    printf '%s\n' 'collection-basic,101' 'geometry,102' 'latex-bin,103' > "${TLMGR_INSTALLED_REVISION_FIXTURE}"
    TLMGR_REMOTE_FIXTURE="${TEXENV_ROOT}/remote-revisions.txt"
    cp "${TLMGR_INSTALLED_REVISION_FIXTURE}" "${TLMGR_REMOTE_FIXTURE}"
    TLMGR_REPOSITORY='https://ctan.example.invalid/tlnet'
    export TLMGR_INSTALLED_FIXTURE
    export TLMGR_INSTALLED_REVISION_FIXTURE TLMGR_REMOTE_FIXTURE
    export TLMGR_REPOSITORY
  }
  BeforeEach 'freeze_before'

  invoke_freeze() {
    invoke_in_dir "${TEXENV_SPEC_BIN}/texenv-freeze" "$@"
  }

  freeze_requirements() {
    invoke_freeze > /dev/null \
      && printf '%s\n' collection-basic geometry latex-bin \
      | cmp -s - "${TEXENV_DIR}/${TEX_REQUIREMENTS_FILE}"
  }

  freeze_lock() {
    TLMGR_VERSION_OUTPUT=$'tlmgr revision 12345\nTeX Live (https://tug.org/texlive) version 2025'
    export TLMGR_VERSION_OUTPUT
    invoke_freeze --lock > /dev/null \
      && grep -qxF '# TeX Live: 2025' "${TEXENV_DIR}/${TEX_REQUIREMENTS_LOCK_FILE}"
  }

  freeze_failed_preserves_file() {
    local status
    printf '%s\n' old-package > "${TEXENV_DIR}/${TEX_REQUIREMENTS_FILE}"
    TLMGR_FAIL_INFO=1
    export TLMGR_FAIL_INFO
    if invoke_freeze > /dev/null; then
      status=0
    else
      status=$?
    fi
    test "$(<"${TEXENV_DIR}/${TEX_REQUIREMENTS_FILE}")" = old-package || return 2
    test -z "$(find "${TEXENV_DIR}" -maxdepth 1 -name 'tex-require.txt.*' -print)" || return 3
    return "${status}"
  }

  freeze_lock_repository_query_failure() {
    local status
    printf '%s\n' old-lock > "${TEXENV_DIR}/${TEX_REQUIREMENTS_LOCK_FILE}"
    TLMGR_FAIL_OPTION=1
    export TLMGR_FAIL_OPTION
    if invoke_freeze --lock > /dev/null; then
      status=0
    else
      status=$?
    fi
    test "$(<"${TEXENV_DIR}/${TEX_REQUIREMENTS_LOCK_FILE}")" = old-lock || return 2
    test -z "$(find "${TEXENV_DIR}" -maxdepth 1 -name 'tex-require.lock.*' -print)" || return 3
    return "${status}"
  }

  freeze_excludes_hook_stdout() {
    local hook_dir="${TEXENV_HOOKS}/exec-tlmgr/pre"
    mkdir -p "${hook_dir}"
    printf '%s\n' '#!/usr/bin/env bash' 'printf "%s\n" hook-output' > "${hook_dir}/01-noisy-hook.bash"
    chmod +x "${hook_dir}/01-noisy-hook.bash"
    invoke_freeze > /dev/null \
      && printf '%s\n' collection-basic geometry latex-bin \
      | cmp -s - "${TEXENV_DIR}/${TEX_REQUIREMENTS_FILE}"
  }

  freeze_normalizes_platform_packages() {
    printf '%s\n' geometry geometry.universal-darwin bibtex.universal-darwin > "${TEXENV_INSTALLED_FIXTURE}"
    invoke_freeze > /dev/null \
      && printf '%s\n' geometry bibtex \
      | cmp -s - "${TEXENV_DIR}/${TEX_REQUIREMENTS_FILE}"
  }

  It 'writes the installed package list'
    When call freeze_requirements
    The status should equal 0
  End

  It 'writes the TeX Live year in lock files'
    When call freeze_lock
    The status should equal 0
  End

  It 'writes package revisions and the active platform in lock files'
    When call invoke_freeze --lock
    The status should equal 0
    The output should include 'Freezing TeX packages to tex-require.lock...'
    The contents of file "${TEXENV_DIR}/${TEX_REQUIREMENTS_LOCK_FILE}" should include '# texenv-lock: 2'
    The contents of file "${TEXENV_DIR}/${TEX_REQUIREMENTS_LOCK_FILE}" should include "# Platform: ${TEXENV_PLATFORM}"
    The contents of file "${TEXENV_DIR}/${TEX_REQUIREMENTS_LOCK_FILE}" should include '# Repository Manifest: sha512:'
    The contents of file "${TEXENV_DIR}/${TEX_REQUIREMENTS_LOCK_FILE}" should include $'geometry\t102'
  End

  It 'captures package archives and checksums for lock files'
    TLMGR_BACKUP_LOG="${TEXENV_ROOT}/backup.log"
    export TLMGR_BACKUP_LOG
    When call invoke_freeze --lock --archive
    The status should equal 0
    The output should include 'Freezing TeX packages to tex-require.lock...'
    The contents of file "${TEXENV_DIR}/${TEX_REQUIREMENTS_LOCK_FILE}" should include 'sha512:'
    The file "${TEXENV_CACHE_DIR}/geometry.r102.tar.xz" should be exist
    The contents of file "${TLMGR_BACKUP_LOG}" should equal "${TEXENV_CACHE_DIR}"
  End

  It 'preserves the previous requirements file when tlmgr fails'
    When call freeze_failed_preserves_file
    The status should equal 1
    The stderr should include 'failed to freeze TeX packages'
  End

  It 'preserves the previous lock file when repository lookup fails'
    When call freeze_lock_repository_query_failure
    The status should equal 1
    The stderr should include 'failed to freeze TeX packages'
  End

  It 'does not write hook stdout to the requirements file'
    When call freeze_excludes_hook_stdout
    The status should equal 0
    The stderr should include 'hook-output'
  End

  It 'normalizes platform-specific package names and removes duplicates'
    When call freeze_normalizes_platform_packages
    The status should equal 0
  End

  It 'rejects unknown options'
    When call invoke_freeze --unexpected
    The status should equal 1
    The stderr should include "unknown option '--unexpected'"
  End

  It 'execs help for freeze --help'
    When call invoke_freeze --help
    The status should equal 0
    The output should include 'Usage: texenv freeze'
  End
End
