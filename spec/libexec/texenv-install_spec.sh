#shellcheck shell=bash
# Regression specs for staged TinyTeX installation.

Describe 'texenv-install'
  install_before() {
    texenv_setup
    texenv_install_libexec texenv-install texenv-libs texenv-help
    cp "${SPEC_REPO_ROOT}/spec/support/stubs/curl.sh" "${TEXENV_SPEC_BIN}/curl"
    chmod +x "${TEXENV_SPEC_BIN}/curl"
    OS_NAME="$(uname)"
    ARCH="$(uname -m)"
    TINYTEX_ARCHIVE_EXT='tar.gz'
    export OS_NAME ARCH TINYTEX_ARCHIVE_EXT
    TEXENV_CURL_FIXTURE="${TEXENV_ROOT}/fixture.tar.gz"
    export TEXENV_CURL_FIXTURE
    mkdir -p "${TEXENV_ROOT}/fixture-root/TinyTeX/bin/${TEXENV_PLATFORM}"
  }
  BeforeEach 'install_before'

  make_invalid_archive() {
    printf 'not a tar archive\n' > "${TEXENV_CURL_FIXTURE}"
    set_fixture_digest
  }

  set_fixture_digest() {
    local digest
    if command -v sha256sum >/dev/null 2>&1; then
      read -r digest _ < <(sha256sum "${TEXENV_CURL_FIXTURE}")
    elif command -v shasum >/dev/null 2>&1; then
      read -r digest _ < <(shasum -a 256 "${TEXENV_CURL_FIXTURE}")
    else
      digest="$(openssl dgst -sha256 "${TEXENV_CURL_FIXTURE}")"
      digest="${digest##*= }"
    fi
    TEXENV_CURL_DIGEST="sha256:${digest}"
    export TEXENV_CURL_DIGEST
  }

  make_valid_archive() {
    printf '%s\n' '#!/usr/bin/env bash' 'printf installed' > "${TEXENV_ROOT}/fixture-root/TinyTeX/bin/${TEXENV_PLATFORM}/fakecmd"
    chmod +x "${TEXENV_ROOT}/fixture-root/TinyTeX/bin/${TEXENV_PLATFORM}/fakecmd"
    tar -czf "${TEXENV_CURL_FIXTURE}" -C "${TEXENV_ROOT}/fixture-root" TinyTeX
    set_fixture_digest
  }

  invoke() {
    "${TEXENV_SPEC_BIN}/texenv-install" "${@}"
  }

  invoke_failed_force_install() {
    local status
    mkdir -p "${TEXENV_VERSIONS}/2025.01"
    : > "${TEXENV_VERSIONS}/2025.01/sentinel"
    make_invalid_archive
    if invoke --force 2025.01 > /dev/null; then
      status=0
    else
      status=$?
    fi
    test -e "${TEXENV_VERSIONS}/2025.01/sentinel" || return 2
    test -z "$(find "${TEXENV_VERSIONS}" -maxdepth 1 -name '.texenv-install.*' -o -name '.texenv-backup.*')" || return 3
    return "${status}"
  }

  invoke_successful_install() {
    make_valid_archive
    invoke 2025.01 > /dev/null
    test -x "${TEXENV_VERSIONS}/2025.01/bin/${TEXENV_PLATFORM}/fakecmd"
    test -z "$(find "${TEXENV_VERSIONS}" -maxdepth 1 -name '.texenv-install.*' -o -name '.texenv-backup.*')"
  }

  invoke_successful_force_install() {
    mkdir -p "${TEXENV_VERSIONS}/2025.01"
    : > "${TEXENV_VERSIONS}/2025.01/sentinel"
    make_valid_archive
    invoke --force 2025.01 > /dev/null
    test -x "${TEXENV_VERSIONS}/2025.01/bin/${TEXENV_PLATFORM}/fakecmd"
    test ! -e "${TEXENV_VERSIONS}/2025.01/sentinel"
    test -z "$(find "${TEXENV_VERSIONS}" -maxdepth 1 -name '.texenv-install.*' -o -name '.texenv-backup.*')"
  }

  invoke_failed_post_hook() {
    local status
    mkdir -p "${TEXENV_VERSIONS}/2025.01" "${TEXENV_HOOKS}/install/post"
    : > "${TEXENV_VERSIONS}/2025.01/sentinel"
    printf '%s\n' '#!/usr/bin/env bash' 'exit 1' > "${TEXENV_HOOKS}/install/post/fail"
    chmod +x "${TEXENV_HOOKS}/install/post/fail"
    make_valid_archive
    if invoke --force 2025.01 > /dev/null; then
      status=0
    else
      status=$?
    fi
    test -e "${TEXENV_VERSIONS}/2025.01/sentinel" || return 2
    test ! -e "${TEXENV_VERSIONS}/2025.01/bin/${TEXENV_PLATFORM}/fakecmd" || return 3
    test -z "$(find "${TEXENV_VERSIONS}" -maxdepth 1 -name '.texenv-install.*' -o -name '.texenv-backup.*')" || return 4
    return "${status}"
  }

  invoke_checksum_mismatch() {
    make_valid_archive
    TEXENV_CURL_DIGEST="sha256:$(printf '%064d' 0)"
    export TEXENV_CURL_DIGEST
    if invoke 2025.01 > /dev/null; then
      return 0
    else
      return $?
    fi
  }

  invoke_without_checksum() {
    make_valid_archive
    TEXENV_CURL_DIGEST=""
    export TEXENV_CURL_DIGEST
    if invoke 2025.01 > /dev/null; then
      return 0
    else
      return $?
    fi
  }

  It 'keeps the existing version when force installation fails'
    When call invoke_failed_force_install
    The status should not equal 0
    The stderr should include 'failed to install version 2025.01'
  End

  It 'installs into the final directory only after extraction succeeds'
    When call invoke_successful_install
    The status should equal 0
  End

  It 'removes the old tree after a successful force install'
    When call invoke_successful_force_install
    The status should equal 0
  End

  It 'restores the old tree when a post-install hook fails'
    When call invoke_failed_post_hook
    The status should equal 1
    The stderr should include 'failed to install version 2025.01'
  End

  It 'rejects an archive whose checksum does not match'
    When call invoke_checksum_mismatch
    The status should equal 1
    The stderr should include 'archive checksum mismatch'
  End

  It 'rejects an archive without a published checksum'
    When call invoke_without_checksum
    The status should equal 1
    The stderr should include 'no SHA-256 digest published'
  End
End
