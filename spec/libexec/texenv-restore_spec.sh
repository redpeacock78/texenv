#shellcheck shell=bash
# Spec for libexec/texenv-restore.

Describe 'texenv-restore'
  restore_before() {
    texenv_setup
    texenv_install_libexec texenv-restore texenv-libs texenv-exec texenv-help
    texenv_make_version 2025.01
    texenv_make_version 2024.12
    TLMGR_REPOSITORY='https://ctan.example.invalid/tlnet'
    export TLMGR_REPOSITORY
  }
  BeforeEach 'restore_before'

  setup_required_file() {
    local pkg
    : > "${TEXENV_DIR}/${TEX_REQUIREMENTS_FILE}"
    for pkg in "$@"; do echo "${pkg}"; done >> "${TEXENV_DIR}/${TEX_REQUIREMENTS_FILE}"
  }

  setup_mixed_requirements() {
    printf '# comment\r\npkgA\r\npkgA\r\n# another comment\r\npkgB\r\n' > "${TEXENV_DIR}/${TEX_REQUIREMENTS_FILE}"
  }

  setup_lock_file() {
    local tex_version="$1"; shift
    local pkg
    {
      echo "# TeX Live: ${tex_version}"
      echo "# Repository: ${TLMGR_REPOSITORY}"
      for pkg in "$@"; do echo "${pkg}"; done
    } > "${TEXENV_DIR}/${TEX_REQUIREMENTS_LOCK_FILE}"
  }

  setup_legacy_lock_file() {
    local tex_version="$1"; shift
    local pkg
    {
      echo "# TeX Live: ${tex_version}"
      for pkg in "$@"; do echo "${pkg}"; done
    } > "${TEXENV_DIR}/${TEX_REQUIREMENTS_LOCK_FILE}"
  }

  setup_installed() {
    local pkg
    TLMGR_INSTALLED_FIXTURE="${TEXENV_ROOT}/installed.txt"
    : > "${TLMGR_INSTALLED_FIXTURE}"
    for pkg in "$@"; do echo "${pkg}"; done >> "${TLMGR_INSTALLED_FIXTURE}"
    export TLMGR_INSTALLED_FIXTURE
  }

  setup_installed_revisions() {
    local pkg rev
    TLMGR_INSTALLED_REVISION_FIXTURE="${TEXENV_ROOT}/installed-revisions.txt"
    : > "${TLMGR_INSTALLED_REVISION_FIXTURE}"
    for pkg in "$@"; do
      rev="${pkg##*:}"
      pkg="${pkg%:*}"
      printf '%s,%s\n' "${pkg}" "${rev}" >> "${TLMGR_INSTALLED_REVISION_FIXTURE}"
    done
    export TLMGR_INSTALLED_REVISION_FIXTURE
  }

  setup_remote_revisions() {
    local pkg rev
    TLMGR_REMOTE_FIXTURE="${TEXENV_ROOT}/remote-revisions.txt"
    : > "${TLMGR_REMOTE_FIXTURE}"
    for pkg in "$@"; do
      rev="${pkg##*:}"
      pkg="${pkg%:*}"
      printf '%s,%s\n' "${pkg}" "${rev}" >> "${TLMGR_REMOTE_FIXTURE}"
    done
    export TLMGR_REMOTE_FIXTURE
  }

  setup_revision_lock_file() {
    local tex_version="$1"; shift
    local pkg rev
    local manifest
    manifest="$("${TEXENV_SPEC_BIN}/texenv-libs" normalizePackageRevisions < "${TLMGR_REMOTE_FIXTURE}" | sort | "${TEXENV_SPEC_BIN}/texenv-libs" sha512Stream)"
    {
      echo '# texenv-lock: 2'
      echo "# TeX Live: ${tex_version}"
      echo "# Platform: ${TEXENV_PLATFORM}"
      echo "# Repository: ${TLMGR_REPOSITORY}"
      echo "# Repository Manifest: sha512:${manifest}"
      for pkg in "$@"; do
        rev="${pkg##*:}"
        pkg="${pkg%:*}"
        printf '%s\t%s\n' "${pkg}" "${rev}"
      done
    } > "${TEXENV_DIR}/${TEX_REQUIREMENTS_LOCK_FILE}"
  }

  setup_archive_lock_file() {
    local tex_version="$1" package="$2" revision="$3" manifest checksum archive_dir
    archive_dir="${TEXENV_CACHE_DIR}"
    mkdir -p "${archive_dir}"
    printf 'archive:%s:%s\n' "${package}" "${revision}" > "${archive_dir}/${package}.r${revision}.tar.xz"
    checksum="$("${TEXENV_SPEC_BIN}/texenv-libs" sha512File "${archive_dir}/${package}.r${revision}.tar.xz")"
    manifest="$("${TEXENV_SPEC_BIN}/texenv-libs" normalizePackageRevisions < "${TLMGR_REMOTE_FIXTURE}" | sort | "${TEXENV_SPEC_BIN}/texenv-libs" sha512Stream)"
    {
      echo '# texenv-lock: 2'
      echo "# TeX Live: ${tex_version}"
      echo "# Platform: ${TEXENV_PLATFORM}"
      echo "# Repository: ${TLMGR_REPOSITORY}"
      echo "# Repository Manifest: sha512:${manifest}"
      printf '%s\t%s\tsha512:%s\n' "${package}" "${revision}" "${checksum}"
    } > "${TEXENV_DIR}/${TEX_REQUIREMENTS_LOCK_FILE}"
  }

  invoke() {
    invoke_in_dir "${TEXENV_SPEC_BIN}/texenv-restore" "$@"
  }

  It 'fails when no requirements file is present'
    When call invoke
    The status should equal 1
    The stderr should include 'no requirements file found'
  End

  It 'rejects unknown options'
    When call invoke --unexpected
    The status should equal 1
    The stderr should include "unknown option '--unexpected'"
  End

  It 'rejects option-like package names in lock files'
    set_global_version 2025.01
    setup_installed_revisions pkgA:101
    {
      echo '# texenv-lock: 2'
      echo '# TeX Live: 2025'
      echo "# Platform: ${TEXENV_PLATFORM}"
      echo "# Repository: ${TLMGR_REPOSITORY}"
      printf '%s\t101\n' '--repository=evil'
    } > "${TEXENV_DIR}/${TEX_REQUIREMENTS_LOCK_FILE}"
    When call invoke
    The status should equal 1
    The stderr should include 'invalid package name in lock file'
    The output should not include 'installing:'
  End

  It 'rejects installed package revisions that differ from the lock'
    set_global_version 2025.01
    setup_installed_revisions pkgA:102
    setup_remote_revisions pkgA:101
    setup_revision_lock_file 2025 pkgA:101
    When call invoke
    The status should equal 1
    The stderr should include 'package revision does not match lock file'
    The output should not include 'installing:'
  End

  It 'rejects repository package revisions that differ from the lock'
    set_global_version 2025.01
    setup_installed_revisions pkgA:101
    setup_remote_revisions pkgA:102
    setup_revision_lock_file 2025 pkgA:101
    When call invoke
    The status should equal 1
    The stderr should include 'repository package revisions do not match lock file'
    The output should not include 'installing:'
  End

  It 'restores a mismatched package from a verified archive'
    set_global_version 2025.01
    setup_installed_revisions pkgA:102
    setup_remote_revisions pkgA:101
    setup_archive_lock_file 2025 pkgA 101
    TLMGR_REPOSITORY='https://offline.example.test/tlnet'
    export TLMGR_REPOSITORY
    TLMGR_RESTORE_LOG="${TEXENV_ROOT}/restore.log"
    export TLMGR_RESTORE_LOG
    When call invoke
    The status should equal 0
    The output should include 'restoring: pkgA 101'
    The contents of file "${TLMGR_RESTORE_LOG}" should equal 'pkgA,101,restore'
  End

  It 'rejects a missing archive before restore'
    set_global_version 2025.01
    setup_installed_revisions pkgA:102
    setup_remote_revisions pkgA:101
    setup_archive_lock_file 2025 pkgA 101
    rm -f "${TEXENV_CACHE_DIR}/pkgA.r101.tar.xz"
    When call invoke
    The status should equal 1
    The stderr should include 'archive is missing for pkgA'
    The output should not include 'restoring:'
  End

  It 'rejects a tampered archive before restore'
    set_global_version 2025.01
    setup_installed_revisions pkgA:102
    setup_remote_revisions pkgA:101
    setup_archive_lock_file 2025 pkgA 101
    printf '%s\n' tampered > "${TEXENV_CACHE_DIR}/pkgA.r101.tar.xz"
    When call invoke
    The status should equal 1
    The stderr should include 'archive checksum does not match lock file'
    The output should not include 'restoring:'
  End

  It 'installs missing packages from the plain requirements file'
    set_global_version 2025.01
    setup_installed pkgA
    setup_required_file pkgA pkgB pkgC
    When call invoke
    The status should equal 0
    The output should include "Restoring TeX packages from ${TEX_REQUIREMENTS_FILE}..."
    The line 2 of output should equal 'installing: pkgB pkgC'
    The output should not include 'installing: pkgA'
  End

  It 'supports dry-run without installing packages'
    set_global_version 2025.01
    setup_installed pkgA
    setup_required_file pkgA pkgB pkgC
    TLMGR_INSTALL_LOG="${TEXENV_ROOT}/install.log"
    export TLMGR_INSTALL_LOG
    When call invoke --dry-run
    The status should equal 0
    The output should include 'dry-run: installing: pkgB pkgC'
    The contents of file "${TLMGR_INSTALL_LOG}" should equal 'dry-run'
  End

  It 'normalizes CRLF comments and duplicate requirements'
    set_global_version 2025.01
    setup_installed pkgA
    setup_mixed_requirements
    When call invoke
    The status should equal 0
    The line 2 of output should equal 'installing: pkgB'
    The stderr should not include 'invalid package name'
  End

  It 'fails before installing when the installed package query fails'
    set_global_version 2025.01
    setup_installed pkgA
    setup_required_file pkgA pkgB
    TLMGR_FAIL_INFO=1
    export TLMGR_FAIL_INFO
    When call invoke
    The status should equal 1
    The stderr should include 'failed to read installed TeX packages'
    The output should not include 'installing:'
  End

  It 'prefers the lock file over the plain requirements file when both exist'
    set_global_version 2025.01
    setup_installed pkgA
    setup_required_file pkgA pkgB
    setup_lock_file 2025 pkgA pkgB pkgC
    When call invoke
    The status should equal 0
    The output should include "Restoring TeX packages from ${TEX_REQUIREMENTS_LOCK_FILE}..."
    The line 2 of output should equal 'installing: pkgB pkgC'
    The output should not include 'installing: pkgA'
  End

  It 'normalizes platform-specific package names in lock files'
    set_global_version 2025.01
    setup_installed pkgA.universal-darwin
    setup_lock_file 2025 pkgA pkgB.universal-darwin
    When call invoke
    The status should equal 0
    The line 2 of output should equal 'installing: pkgB'
    The output should not include 'installing: pkgA'
  End

  It 'fails before installing when the lock repository differs'
    set_global_version 2025.01
    setup_installed pkgA
    TLMGR_REPOSITORY='https://locked.example.test/2025/tlnet-final'
    export TLMGR_REPOSITORY
    setup_lock_file 2025 pkgA pkgB
    TLMGR_REPOSITORY='https://current.example.test/tlnet'
    export TLMGR_REPOSITORY
    When call invoke
    The status should equal 1
    The stderr should include 'repository does not match lock file'
    The output should not include 'installing:'
  End

  It 'accepts a legacy lock file without repository metadata'
    set_global_version 2025.01
    setup_installed pkgA
    setup_legacy_lock_file 2025 pkgA pkgB
    When call invoke
    The status should equal 0
    The line 2 of output should equal 'installing: pkgB'
  End

  It 'errors when current TeX version is older than the lock header version'
    set_global_version 2024.12
    setup_installed pkgA
    setup_lock_file 2025 pkgA pkgB
    When call invoke
    The status should equal 1
    The stderr should include 'older than the required version'
  End

  It 'accepts a daily version when its year satisfies the lock header'
    set_global_version daily-2026.08.23
    texenv_make_version daily-2026.08.23
    setup_installed pkgA
    setup_lock_file 2025 pkgA pkgB
    When call invoke
    The status should equal 0
    The line 2 of output should equal 'installing: pkgB'
  End

  It 'skips install and reports already-installed when no packages are missing'
    set_global_version 2025.01
    setup_installed pkgA pkgB pkgC
    setup_required_file pkgA pkgB pkgC
    When call invoke
    The status should equal 0
    The output should include 'All required TeX packages are already installed.'
    The output should not include 'installing:'
  End

  It 'excludes the lock header line when computing the diff'
    set_global_version 2025.01
    setup_installed pkgA
    setup_lock_file 2025 pkgA pkgB
    When call invoke
    The status should equal 0
    The output should include 'installing: pkgB'
    The output should not include 'installing: # TeX Live: 2025'
  End

  It 'detects missing packages even when installed and required are in different order'
    set_global_version 2025.01
    setup_installed pkgC pkgA
    setup_required_file pkgA pkgB pkgC
    When call invoke
    The status should equal 0
    The line 2 of output should equal 'installing: pkgB'
    The output should not include 'installing: pkgA'
    The output should not include 'installing: pkgC'
  End

  It 'treats an empty requirements file as nothing to install'
    set_global_version 2025.01
    setup_installed pkgA pkgB
    : > "${TEXENV_DIR}/${TEX_REQUIREMENTS_FILE}"
    When call invoke
    The status should equal 0
    The output should include 'All required TeX packages are already installed.'
    The output should not include 'installing:'
  End

  It 'rejects option-like package names in requirements'
    set_global_version 2025.01
    setup_installed pkgA
    setup_required_file --repository=evil
    When call invoke
    The status should equal 1
    The output should include 'Restoring TeX packages from tex-require.txt...'
    The stderr should include 'invalid package name in requirements'
  End
End
