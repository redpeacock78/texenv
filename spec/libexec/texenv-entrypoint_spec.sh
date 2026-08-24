#shellcheck shell=bash
# Regression specs for entrypoint path resolution without readlink.

Describe 'texenv entrypoint'
  entrypoint_before() {
    texenv_setup
  }
  BeforeEach 'entrypoint_before'

  invoke_without_readlink() {
    local tool_dir
    local tool
    tool_dir="${TEXENV_ROOT}/minimal bin"
    mkdir -p "${tool_dir}"
    for tool in bash env uname ls; do
      ln -s "$(command -v "${tool}")" "${tool_dir}/${tool}"
    done
    ln -s "${SPEC_REPO_ROOT}/bin/texenv" "${tool_dir}/texenv"
    PATH="${tool_dir}" "${tool_dir}/texenv" help
  }

  It 'starts when readlink is unavailable'
    When call invoke_without_readlink
    The status should equal 0
    The output should include 'USAGE: texenv <command>'
    The stderr should equal ''
  End
End
