#shellcheck shell=bash
# Specs for read-only environment diagnostics.

Describe 'texenv-doctor'
  doctor_before() {
    texenv_setup
    texenv_install_libexec texenv-doctor texenv-libs texenv-help
    texenv_make_version 2025.01
    set_global_version 2025.01
    setup_version_bin_command 2025.01 kpsewhich
    setup_version_bin_command 2025.01 pdftex
    printf '%s\n' '#!/usr/bin/env bash' 'exit 0' > "${TEXENV_SPEC_BIN}/perl"
    chmod +x "${TEXENV_SPEC_BIN}/perl"
    PATH="${TEXENV_BIN}:${TEXENV_SHIMS}:${PATH}"
    export PATH
  }
  BeforeEach 'doctor_before'

  setup_required_file() {
    local pkg
    : > "${TEXENV_DIR}/${TEX_REQUIREMENTS_FILE}"
    for pkg in "$@"; do printf '%s\n' "${pkg}"; done >> "${TEXENV_DIR}/${TEX_REQUIREMENTS_FILE}"
  }

  setup_installed() {
    local pkg
    TLMGR_INSTALLED_FIXTURE="${TEXENV_ROOT}/installed.txt"
    : > "${TLMGR_INSTALLED_FIXTURE}"
    for pkg in "$@"; do printf '%s\n' "${pkg}"; done >> "${TLMGR_INSTALLED_FIXTURE}"
    export TLMGR_INSTALLED_FIXTURE
  }

  invoke_doctor() {
    invoke_in_dir "${TEXENV_SPEC_BIN}/texenv-doctor" "$@"
  }

  invoke_doctor_with_failed_check() {
    env TLMGR_FAIL_CHECK=1 "${TEXENV_SPEC_BIN}/texenv-doctor"
  }

  It 'reports a healthy environment'
    When call invoke_doctor
    The status should equal 0
    The output should include '[OK] active version: 2025.01'
    The output should include '[OK] tlmgr check all'
    The output should include '[OK] requirements: no snapshot'
  End

  It 'fails when no active version is selected'
    : > "${TEXENV_ROOT}/${TEX_GLOBAL_VERSION_FILE}"
    When call invoke_doctor
    The status should equal 1
    The output should include '[FAIL] active version: not set'
  End

  It 'fails when tlmgr check all fails'
    When call invoke_doctor_with_failed_check
    The status should equal 1
    The output should include '[FAIL] tlmgr check all'
  End

  It 'warns when requirements contain missing packages'
    setup_installed pkgA
    setup_required_file pkgA pkgB
    When call invoke_doctor
    The status should equal 0
    The output should include '[WARN] requirements: 1 package(s) missing'
  End

  It 'execs help for doctor --help'
    When call invoke_doctor --help
    The status should equal 0
    The output should include 'Usage: texenv doctor'
  End
End
