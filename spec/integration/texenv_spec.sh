#shellcheck shell=bash
# End-to-end specs for the public texenv entrypoint.

Describe 'texenv command integration'
  integration_before() {
    local fakecmd
    texenv_setup
    texenv_make_version 2025.01
    setup_version_bin_command 2025.01 fakecmd
    fakecmd="${TEXENV_VERSIONS}/2025.01/bin/${TEXENV_PLATFORM}/fakecmd"
    printf '%s\n' '#!/usr/bin/env bash' 'printf "fakecmd:%s\n" "$*"' > "${fakecmd}"
    chmod +x "${fakecmd}"
    printf '%s\n' '#!/usr/bin/env bash' 'exit 0' > "${TEXENV_SPEC_BIN}/perl"
    chmod +x "${TEXENV_SPEC_BIN}/perl"
  }
  BeforeEach 'integration_before'

  invoke_cli() {
    invoke_in_dir "${SPEC_REPO_ROOT}/bin/texenv" "$@"
  }

  setup_revision_fixture() {
    TLMGR_VERSION_OUTPUT=$'tlmgr revision 12345\nTeX Live (https://tug.org/texlive) version 2025'
    TLMGR_INSTALLED_FIXTURE="${TEXENV_ROOT}/installed.txt"
    printf '%s\n' collection-basic geometry latex-bin > "${TLMGR_INSTALLED_FIXTURE}"
    TLMGR_INSTALLED_REVISION_FIXTURE="${TEXENV_ROOT}/installed-revisions.txt"
    printf '%s\n' 'collection-basic,101' 'geometry,102' 'latex-bin,103' > "${TLMGR_INSTALLED_REVISION_FIXTURE}"
    TLMGR_REMOTE_FIXTURE="${TEXENV_ROOT}/remote-revisions.txt"
    cp "${TLMGR_INSTALLED_REVISION_FIXTURE}" "${TLMGR_REMOTE_FIXTURE}"
    TLMGR_REPOSITORY='https://ctan.example.invalid/tlnet'
    export TLMGR_VERSION_OUTPUT TLMGR_INSTALLED_FIXTURE
    export TLMGR_INSTALLED_REVISION_FIXTURE TLMGR_REMOTE_FIXTURE TLMGR_REPOSITORY
  }

  run_local_exec() {
    invoke_cli local 2025.01 &&
      invoke_cli version &&
      invoke_cli exec fakecmd 'arg with spaces'
  }

  run_archive_lifecycle() {
    setup_revision_fixture
    invoke_cli global 2025.01 &&
      invoke_cli freeze --lock --archive &&
      printf '%s\n' 'collection-basic,101' 'geometry,999' 'latex-bin,103' > "${TLMGR_INSTALLED_REVISION_FIXTURE}" &&
      TLMGR_REPOSITORY='https://offline.example.invalid/tlnet' &&
      export TLMGR_REPOSITORY &&
      invoke_cli restore
  }

  run_doctor_flow() {
    setup_revision_fixture
    setup_version_bin_command 2025.01 kpsewhich
    setup_version_bin_command 2025.01 pdftex
    invoke_cli global 2025.01 &&
      invoke_cli freeze --lock > /dev/null &&
      invoke_cli doctor
  }

  It 'runs project version selection and command execution through the entrypoint'
    When call run_local_exec
    The status should equal 0
    The output should include '2025.01'
    The output should include 'fakecmd:arg with spaces'
  End

  It 'runs lock archive freeze and restore through the entrypoint'
    When call run_archive_lifecycle
    The status should equal 0
    The output should include 'Freezing TeX packages to tex-require.lock...'
    The output should include 'restoring: geometry 102'
    The file "${TEXENV_CACHE_DIR}/geometry.r102.tar.xz" should be exist
    The contents of file "${TEXENV_DIR}/${TEX_REQUIREMENTS_LOCK_FILE}" should include $'geometry\t102\tsha512:'
    The contents of file "${TLMGR_INSTALLED_REVISION_FIXTURE}" should include 'geometry,102'
  End

  It 'runs doctor against a frozen environment through the entrypoint'
    When call run_doctor_flow
    The status should equal 0
    The output should include '[OK] active version: 2025.01'
    The output should include '[OK] tlmgr check all'
    The output should include '[OK] requirements: in sync'
  End
End
