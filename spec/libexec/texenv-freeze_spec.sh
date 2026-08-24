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
    export TLMGR_INSTALLED_FIXTURE
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
      && printf '%s\n' '# TeX Live: 2025' collection-basic geometry latex-bin \
      | cmp -s - "${TEXENV_DIR}/${TEX_REQUIREMENTS_LOCK_FILE}"
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

  It 'writes the installed package list'
    When call freeze_requirements
    The status should equal 0
  End

  It 'writes the TeX Live year in lock files'
    When call freeze_lock
    The status should equal 0
  End

  It 'preserves the previous requirements file when tlmgr fails'
    When call freeze_failed_preserves_file
    The status should equal 1
    The stderr should include 'failed to freeze TeX packages'
  End

  It 'execs help for freeze --help'
    When call invoke_freeze --help
    The status should equal 0
    The output should include 'Usage: texenv freeze'
  End
End
