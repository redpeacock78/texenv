#shellcheck shell=bash
# Spec for libexec/texenv-whence.

Describe 'texenv-whence'
  whence_before() {
    texenv_setup
    texenv_install_libexec texenv-whence texenv-help
  }
  BeforeEach 'whence_before'

  invoke() {
    invoke_in_dir "${TEXENV_SPEC_BIN}/texenv-whence" "$@"
  }

  It 'finds a command via filesystem search across versions'
    setup_version_bin_command 2025.01 pdflatex
    setup_version_bin_command 2024.12 pdflatex
    When call invoke pdflatex
    The status should equal 0
    The line 1 of output should equal "2024.12 => ${TEXENV_VERSIONS}/2024.12/bin/${TEXENV_PLATFORM}/pdflatex"
    The line 2 of output should equal "2025.01 => ${TEXENV_VERSIONS}/2025.01/bin/${TEXENV_PLATFORM}/pdflatex"
  End

  It 'uses the command list cache when present'
    setup_version_bin_command 2025.01 pdflatex
    cat > "${TEX_CMD_LIST_CACHE}" <<EOF
${TEXENV_VERSIONS}/2025.01/bin/${TEXENV_PLATFORM}/pdflatex
${TEXENV_VERSIONS}/2024.12/bin/${TEXENV_PLATFORM}/pdflatex
EOF
    When call invoke pdflatex
    The status should equal 0
    The line 1 of output should equal "2024.12 => ${TEXENV_VERSIONS}/2024.12/bin/${TEXENV_PLATFORM}/pdflatex"
    The line 2 of output should equal "2025.01 => ${TEXENV_VERSIONS}/2025.01/bin/${TEXENV_PLATFORM}/pdflatex"
  End

  It 'errors when no versions directory exists'
    rm -rf "${TEXENV_VERSIONS}"
    When call invoke pdflatex
    The status should equal 1
    The stderr should include 'no versions installed'
  End

  It 'errors when no command argument is given'
    When call invoke
    The status should equal 1
    The stderr should include 'no command specified'
  End

  It 'errors when the command is not in any version'
    setup_version_bin_command 2025.01 pdflatex
    When call invoke missing
    The status should equal 1
    The stderr should include "command 'missing' not found"
  End

  It 'execs texenv-help whence when -h is given'
    When call invoke -h
    The status should equal 0
    The output should include 'Usage: texenv whence'
  End

  It 'errors when texenv-help is missing'
    rm -f "${TEXENV_SPEC_BIN}/texenv-help"
    When call invoke
    The status should equal 1
    The stderr should include 'required component(s) missing'
  End
End
