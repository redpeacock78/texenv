#shellcheck shell=bash
# Specs for command execution, hooks, quoting, and lazy tlmgr checks.

Describe 'texenv-exec'
  exec_before() {
    texenv_setup
    texenv_install_libexec texenv-exec texenv-libs texenv-help
    texenv_make_version 2025.01
    set_global_version 2025.01
    printf '%s\n' '#!/usr/bin/env bash' 'printf "fake:%s\\n" "$*"' > "${TEXENV_VERSIONS}/2025.01/bin/${TEXENV_PLATFORM}/fakecmd"
    chmod +x "${TEXENV_VERSIONS}/2025.01/bin/${TEXENV_PLATFORM}/fakecmd"
  }
  BeforeEach 'exec_before'

  invoke() {
    "${TEXENV_SPEC_BIN}/texenv-exec" "$@"
  }

  verify_lazy_tlmgr() {
    invoke fakecmd
    invoke tlmgr
  }

  It 'preserves arguments containing spaces'
    When call invoke fakecmd 'arg with spaces'
    The status should equal 0
    The output should equal 'fake:arg with spaces'
  End

  It 'rejects an invalid command name before execution'
    When call invoke ../outside
    The status should equal 1
    The stderr should include 'invalid command identifier'
  End

  It 'reports a missing command'
    When call invoke missingcmd
    The status should equal 1
    The stderr should include "command 'missingcmd' not found in version '2025.01'"
  End

  It 'runs base and command-specific hooks in order'
    hook_dir="${TEXENV_HOOKS}/exec"
    mkdir -p "${hook_dir}/pre" "${hook_dir}/post" "${TEXENV_HOOKS}/exec-fakecmd/pre" "${TEXENV_HOOKS}/exec-fakecmd/post"
    TEXENV_HOOK_LOG="${TEXENV_ROOT}/hooks.log"
    export TEXENV_HOOK_LOG
    for pair in \
      'exec/pre/base-pre' \
      'exec-fakecmd/pre/command-pre' \
      'exec/post/base-post' \
      'exec-fakecmd/post/command-post'; do
      event_phase="${pair%/*}"
      hook_name="${pair##*/}"
      printf '%s\n' '#!/usr/bin/env bash' "printf '%s\\n' '${hook_name}' >> \"\${TEXENV_HOOK_LOG}\"" > "${TEXENV_HOOKS}/${event_phase}/${hook_name}"
      chmod +x "${TEXENV_HOOKS}/${event_phase}/${hook_name}"
    done
    When call invoke fakecmd
    The status should equal 0
    The output should equal 'fake:'
    The contents of file "${TEXENV_HOOK_LOG}" should equal \
      $'base-pre\ncommand-pre\nbase-post\ncommand-post'
  End

  It 'checks Perl only on the tlmgr path'
    printf '%s\n' '#!/usr/bin/env bash' 'exit 1' > "${TEXENV_SPEC_BIN}/perl"
    chmod +x "${TEXENV_SPEC_BIN}/perl"
    When call verify_lazy_tlmgr
    The status should equal 1
    The output should include 'fake:'
    The stderr should include 'File::Find is required for tlmgr'
  End

  It 'execs help for -h'
    When call invoke -h
    The status should equal 0
    The output should include 'Usage: texenv exec'
  End

  It 'fails when no version is selected'
    : > "${TEXENV_ROOT}/version"
    When call invoke fakecmd
    The status should equal 1
    The stderr should include 'no version set'
  End
End
