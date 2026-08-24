#shellcheck shell=bash
# Specs for all-version command lookup.

Describe 'texenv-whence'
  whence_before() {
    texenv_setup
    texenv_install_libexec texenv-whence texenv-libs texenv-help
    texenv_make_version 2024.09
    texenv_make_version 2025.01
    setup_version_bin_command 2024.09 pdflatex
    setup_version_bin_command 2025.01 pdflatex
  }
  BeforeEach 'whence_before'

  invoke() {
    "${TEXENV_SPEC_BIN}/texenv-whence" "$@"
  }

  invoke_without_help() {
    PATH="${PATH#${TEXENV_SPEC_BIN}:}" "${TEXENV_SPEC_BIN}/texenv-whence" "$@"
  }

  It 'finds commands by scanning installed versions'
    When call invoke pdflatex
    The status should equal 0
    The line 1 of output should equal "2024.09 => ${TEXENV_VERSIONS}/2024.09/bin/${TEXENV_PLATFORM}/pdflatex"
    The line 2 of output should equal "2025.01 => ${TEXENV_VERSIONS}/2025.01/bin/${TEXENV_PLATFORM}/pdflatex"
  End

  It 'uses full paths from the command cache'
    printf '%s\n' \
      "${TEXENV_VERSIONS}/2025.01/bin/${TEXENV_PLATFORM}/pdflatex" \
      "${TEXENV_VERSIONS}/2024.09/bin/${TEXENV_PLATFORM}/pdflatex" > "${TEX_CMD_LIST_CACHE}"
    When call invoke pdflatex
    The status should equal 0
    The line 1 of output should equal "2024.09 => ${TEXENV_VERSIONS}/2024.09/bin/${TEXENV_PLATFORM}/pdflatex"
    The line 2 of output should equal "2025.01 => ${TEXENV_VERSIONS}/2025.01/bin/${TEXENV_PLATFORM}/pdflatex"
  End

  It 'falls back to find when a cached path is stale'
    printf '%s\n' "${TEXENV_VERSIONS}/2024.09/bin/${TEXENV_PLATFORM}/pdflatex" > "${TEX_CMD_LIST_CACHE}"
    mv "${TEXENV_VERSIONS}/2024.09" "${SHELLSPEC_TMPBASE}/removed-2024.09-${SHELLSPEC_EXAMPLE_ID}"
    When call invoke pdflatex
    The status should equal 0
    The output should include '2025.01 =>'
    The output should not include '2024.09 =>'
  End

  It 'reports when the versions directory is unavailable'
    TEXENV_VERSIONS="${TEXENV_ROOT}/missing"
    export TEXENV_VERSIONS
    When call invoke pdflatex
    The status should equal 1
    The stderr should include 'no versions installed'
  End

  It 'reports a missing command argument'
    When call invoke
    The status should equal 1
    The stderr should include 'no command specified'
  End

  It 'reports a command absent from every version'
    When call invoke missingcmd
    The status should equal 1
    The stderr should include "command 'missingcmd' not found"
  End

  It 'rejects a path traversal command name'
    When call invoke ../outside
    The status should equal 1
    The stderr should include 'invalid command identifier'
  End

  It 'execs help for -h'
    When call invoke -h
    The status should equal 0
    The output should include 'Usage: texenv whence'
  End

  It 'execs help for --help'
    When call invoke --help
    The status should equal 0
    The output should include 'Usage: texenv whence'
  End

  It 'fails clearly when a dependency is unavailable'
    When call invoke_without_help pdflatex
    The status should equal 1
    The stderr should include 'required component(s) missing'
  End

  It 'fails clearly when texenv-help is unavailable'
    rm -f "${TEXENV_SPEC_BIN}/texenv-help"
    When call invoke pdflatex
    The status should equal 1
    The stderr should include 'required component(s) missing'
  End
End
