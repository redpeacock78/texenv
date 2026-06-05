#shellcheck shell=bash
# Spec for libexec/texenv-shims.

Describe 'texenv-shims'
  shims_before() {
    texenv_setup
    texenv_install_libexec texenv-shims texenv-help
  }
  BeforeEach 'shims_before'

  invoke() {
    invoke_in_dir "${TEXENV_SPEC_BIN}/texenv-shims" "$@"
  }

  make_shim_link() {
    local name="$1"
    ln -sf /usr/bin/true "${TEXENV_SHIMS}/${name}"
  }

  It 'lists symlinks under TEXENV_SHIMS sorted'
    make_shim_link pdflatex
    make_shim_link bibtex
    make_shim_link xelatex
    When call invoke
    The status should equal 0
    The line 1 of output should end with '/bibtex'
    The line 2 of output should end with '/pdflatex'
    The line 3 of output should end with '/xelatex'
  End

  It 'execs texenv-help shims when -h is given'
    When call invoke -h
    The status should equal 0
    The output should include 'Usage: texenv shims'
  End

  It 'execs texenv-help shims when --help is given'
    When call invoke --help
    The status should equal 0
    The output should include 'Usage: texenv shims'
  End

  It 'errors when no shims are generated'
    When call invoke
    The status should equal 1
    The stderr should include 'no shims generated'
  End

  It 'errors when texenv-help is missing'
    rm -f "${TEXENV_SPEC_BIN}/texenv-help"
    When call invoke
    The status should equal 1
    The stderr should include 'required component(s) missing'
  End
End
