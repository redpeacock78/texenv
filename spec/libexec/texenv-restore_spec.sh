#shellcheck shell=bash
# Spec for libexec/texenv-restore.

Describe 'texenv-restore'
  restore_before() {
    texenv_setup
    texenv_install_libexec texenv-restore texenv-libs texenv-exec texenv-help
    texenv_make_version 2025.01
    texenv_make_version 2024.12
  }
  BeforeEach 'restore_before'

  setup_required_file() {
    local pkg
    : > "${TEXENV_DIR}/${TEX_REQUIREMENTS_FILE}"
    for pkg in "$@"; do echo "${pkg}"; done >> "${TEXENV_DIR}/${TEX_REQUIREMENTS_FILE}"
  }

  setup_lock_file() {
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

  set_global_version() {
    echo "$1" > "${TEXENV_ROOT}/${TEX_GLOBAL_VERSION_FILE}"
  }

  invoke() {
    ( cd "${TEXENV_DIR}" && "${TEXENV_SPEC_BIN}/texenv-restore" "$@" )
  }

  It 'fails when no requirements file is present'
    When call invoke
    The status should equal 1
    The stderr should include 'no requirements file found'
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

  It 'errors when current TeX version is older than the lock header version'
    set_global_version 2024.12
    setup_installed pkgA
    setup_lock_file 2025 pkgA pkgB
    When call invoke
    The status should equal 1
    The stderr should include 'older than the required version'
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
End
