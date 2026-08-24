#shellcheck shell=bash
# Specs for repository selection and mirror persistence.

Describe 'texenv-repo'
  repo_before() {
    texenv_setup
    texenv_install_libexec texenv-repo texenv-libs texenv-help
    texenv_make_version 2025.01
    set_global_version 2025.01
    TLMGR_REPOSITORY_FILE="${TEXENV_ROOT}/tlmgr-repository"
    export TLMGR_REPOSITORY_FILE
  }
  BeforeEach 'repo_before'

  invoke_repo() {
    "${TEXENV_SPEC_BIN}/texenv-repo" "$@"
  }

  mirror_file() {
    printf '%s/%s/mirror_repo.txt\n' "${TEXENV_CONFIG}" 2025.01
  }

  set_repository() {
    printf '%s\n' "$1" > "${TLMGR_REPOSITORY_FILE}"
  }

  mirror_success() {
    local mirror='https://mirror.example.test/texlive/tlnet'
    invoke_repo --mirror "${mirror}" > /dev/null \
      && test "$(<"$(mirror_file)")" = "${mirror}" \
      && test "$(<"${TLMGR_REPOSITORY_FILE}")" = "${mirror}"
  }

  mirror_failed_preserves_state() {
    local status
    local old='https://old.example.test/tlnet'
    set_repository "${old}"
    TLMGR_FAIL_REPOSITORY=1
    export TLMGR_FAIL_REPOSITORY
    if invoke_repo --mirror https://mirror.example.test/tlnet > /dev/null; then
      status=0
    else
      status=$?
    fi
    test "$(<"${TLMGR_REPOSITORY_FILE}")" = "${old}" || return 2
    test ! -e "$(mirror_file)" || return 3
    return "${status}"
  }

  invalid_mirror_is_rejected() {
    local status
    if invoke_repo --mirror '../not-a-url' > /dev/null; then
      status=0
    else
      status=$?
    fi
    test ! -e "$(mirror_file)" || return 2
    return "${status}"
  }

  reset_success_removes_mirror() {
    set_repository https://mirror.example.test/tlnet
    mkdir -p "${TEXENV_CONFIG}/2025.01"
    printf '%s\n' https://mirror.example.test/tlnet > "$(mirror_file)"
    invoke_repo --reset > /dev/null \
      && test ! -e "$(mirror_file)" \
      && test "$(<"${TLMGR_REPOSITORY_FILE}")" = 'https://ctan.math.illinois.edu/systems/texlive/tlnet'
  }

  reset_failed_preserves_mirror() {
    local status
    set_repository https://mirror.example.test/tlnet
    mkdir -p "${TEXENV_CONFIG}/2025.01"
    printf '%s\n' https://mirror.example.test/tlnet > "$(mirror_file)"
    TLMGR_FAIL_REPOSITORY=1
    export TLMGR_FAIL_REPOSITORY
    if invoke_repo --reset > /dev/null; then
      status=0
    else
      status=$?
    fi
    test -e "$(mirror_file)" || return 2
    test "$(<"${TLMGR_REPOSITORY_FILE}")" = 'https://mirror.example.test/tlnet' || return 3
    return "${status}"
  }

  It 'shows the current repository'
    set_repository https://mirror.example.test/tlnet
    When call invoke_repo --show
    The status should equal 0
    The output should equal 'https://mirror.example.test/tlnet'
  End

  It 'persists a successful mirror change'
    When call mirror_success
    The status should equal 0
  End

  It 'does not persist a mirror when tlmgr rejects it'
    When call mirror_failed_preserves_state
    The status should equal 1
    The stderr should include 'failed to set tlmgr repository'
  End

  It 'rejects non-URL mirrors'
    When call invalid_mirror_is_rejected
    The status should equal 1
    The stderr should include 'invalid mirror repository URL'
  End

  It 'removes a mirror after a successful reset'
    When call reset_success_removes_mirror
    The status should equal 0
  End

  It 'keeps a mirror when reset fails'
    When call reset_failed_preserves_mirror
    The status should equal 1
    The stderr should include 'failed to set tlmgr repository'
  End
End
