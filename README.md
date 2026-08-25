<!-- English README -->

<div align="center">

![Last commit](https://img.shields.io/github/last-commit/redpeacock78/texenv?style=flat-square)
![Repository Stars](https://img.shields.io/github/stars/redpeacock78/texenv?style=flat-square)
![Issues](https://img.shields.io/github/issues/redpeacock78/texenv?style=flat-square)
![Open Issues](https://img.shields.io/github/issues-raw/redpeacock78/texenv?style=flat-square)
![Bug Issues](https://img.shields.io/github/issues/redpeacock78/texenv/bug?style=flat-square)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/redpeacock78/texenv)
<br>
<img src="https://www.emoji.family/api/emojis/%F0%9F%93%9D/twemoji/svg" alt="eyecatch" height="100">

# texenv

A Bash version manager for TinyTeX, the minimal TeX Live distribution.

texenv installs multiple TinyTeX releases, selects a TeX Live version for each project, and runs TeX commands through shims.

It does not modify TeX Live installations managed outside texenv.

<br>
<br>

</div>

<table>
  <thead>
    <tr>
      <th style="text-align:center">🍔English</th>
      <th style="text-align:center"><a href="README.ja.md">🍡日本語</a></th>
    </tr>
  </thead>
</table>

## 🚀 How to use

### Quick start

Clone texenv and initialize the shell integration.

```bash
git clone https://github.com/redpeacock78/texenv.git "${HOME}/.texenv"
eval "$("${HOME}/.texenv/bin/texenv" init -)"
texenv init
```

Install a TinyTeX release, select it globally, and build the shims.

```bash
texenv install 2026.04
texenv global 2026.04
texenv rehash
```

Select a version for the current project and run a TeX command.

```bash
texenv local 2026.04
pdflatex main.tex
```

### Version selection

`global` selects the default version.

`local` writes `.tex-version` in the current project directory.

texenv also searches parent directories for a local version, which takes precedence over the global version.

`shell` selects a version only for the current shell.

```bash
texenv global 2026.04
texenv local 2026.04
eval "$(texenv shell 2026.04)"
texenv version
texenv versions
```

### Running TeX commands

Run commands explicitly through the selected version with `exec`.

```bash
texenv exec pdflatex main.tex
texenv exec tlmgr info geometry
```

After `rehash`, TeX executables can be invoked directly through shims.

```bash
texenv rehash
pdflatex main.tex
```

The Perl and `File::Find` check is lazy for command execution and runs when texenv executes `tlmgr`.

`doctor` reports this prerequisite explicitly.

Ordinary TeX command execution does not perform this check.

### Freezing and restoring packages

Save installed package names to `tex-require.txt`.

```bash
texenv freeze
```

Create a lock file with the TeX Live year, platform, repository, package revisions, and repository manifest.

```bash
texenv freeze --lock
```

The lock records the installed `localrev` for each package and a hash of the matching repository revision manifest.

`restore` verifies the TeX Live year, platform, repository, and package revisions before installing missing packages.

```bash
texenv restore
```

If an installed package has a different revision and no archive is available, restore stops instead of silently installing another revision.

Create a lock file with local package archives for offline restore or revision rollback.

```bash
texenv freeze --lock --archive
texenv restore
```

The archives are stored in `.texenv/cache/` in the project directory.

Each archive is verified against its SHA-512 value before `tlmgr restore` runs.

A complete archive lock does not need to contact the TeX Live repository.

`--archive` requires `--lock`.

Use `--dry-run` to inspect a restore without installing or restoring packages.

Restore never removes packages that are absent from the requirements file.

### Managing the tlmgr repository

Show the current repository.

```bash
texenv repo --show
```

Set a mirror for the selected TeX Live version.

```bash
texenv repo --mirror https://mirror.example.org/tex-archive/systems/texlive/tlnet
```

Reset the repository to the default selection.

```bash
texenv repo --reset
```

### Finding commands

Use `which` for the shim path, `where` for the executable in the selected version, and `whence` for every installed version.

```bash
texenv which pdflatex
texenv where pdflatex
texenv whence pdflatex
```

### Diagnosing the environment

`doctor` performs read-only checks for the active version, required commands, TeX commands, Perl support for `tlmgr`, shims, command cache, and package snapshot status.

```bash
texenv doctor
texenv env
texenv root
texenv shims
texenv commands
```

## ⬇️ Install

### Supported platforms

- macOS (Darwin)
- Linux x86_64
- Linux ARM64 (aarch64 or arm64)

texenv exits at startup on unsupported operating systems and architectures.

### Shell and commands

Bash 4.x or later is required.

zsh users should evaluate the output of `texenv init -` from their shell configuration.

The following commands are required:

- `bash`
- `curl`
- `tar`
- `find`
- `grep`
- `awk`
- `diff`
- `cat`
- `mkdir`
- `mktemp`
- `mv`
- `ln`
- `chmod`
- `touch`
- `date`
- `uname`
- `sort`
- `tr`
- `rm`
- `ls`
- One of `sha256sum`, `shasum`, or `openssl`

`readlink` is optional.

When available, texenv uses it to resolve symbolic links.

When it is unavailable, texenv falls back to `ls -dl`.

`jq` is optional and is used to parse the GitHub Releases API response when installed.

Without `jq`, texenv parses only the asset information it needs.

Perl and the `File::Find` module are required only when running `tlmgr`.

TinyTeX invokes `tlmgr` through Perl, so ordinary TeX command execution does not perform this check.

See the [TinyTeX documentation](https://yihui.org/tinytex/) and [TinyTeX issue #419](https://github.com/rstudio/tinytex/issues/419) for details.

Network access to the GitHub Releases API, TinyTeX archives, and TeX Live repositories is required for installation and repository-based restore.

### Installing with anyenv

If you use [anyenv](https://github.com/anyenv/anyenv), install texenv with:

```bash
rm -rf "${HOME}/.config/anyenv/anyenv-install"
anyenv install --init https://github.com/redpeacock78/anyenv-install.git texenv-add
anyenv install texenv
```

Add the following line to your shell configuration.

```bash
eval "$(anyenv init -)"
```

### Installing from Git

The quick-start commands install texenv from Git into `~/.texenv`.

Run `texenv init` after loading the shell configuration.

TinyTeX release archives are checked against the SHA-256 digest published by the GitHub Releases API before extraction.

Installation stops when the digest is missing, does not match, or no supported SHA-256 command is available.

macOS normally uses `.tgz` archives, while Linux normally uses `.tar.gz` archives.

If the corresponding archive is unavailable, texenv falls back to `.tar.xz`.

### Project files and cache

The project-local files are stored in the directory where texenv is invoked.

```text
project/
├── .tex-version
├── tex-require.txt
├── tex-require.lock
└── .texenv/
    └── cache/
```

`.tex-version`, `tex-require.txt`, and `tex-require.lock` are project files and can be versioned.

`.texenv/` is a runtime cache and is ignored by default.

The cache contains package archives created by `tlmgr backup` when `freeze --lock --archive` is used.

### Directory layout

The default texenv directory is:

```text
~/.texenv/
├── bin/texenv
├── shims/
├── versions/
├── config/
├── hooks/
├── texmf/
└── version
```

`versions/` stores the extracted TinyTeX tree for each version.

`shims/` stores shims that dispatch to the selected version.

`config/` stores the command cache and per-version mirror settings.

`texmf/` is used as the user-level `TEXMF_HOME` directory.

### Removing and updating texenv

Remove an installed version with:

```bash
texenv uninstall 2026.04
```

Select another global or local version before removing the currently selected version.

Update a Git checkout with:

```bash
cd "${HOME}/.texenv"
git pull --ff-only
texenv rehash
```

To remove texenv, delete `${HOME}/.texenv`, remove the initialization command from your shell configuration, and remove the texenv paths from `PATH`.

## ⛏️ Development

Use [ShellSpec](https://github.com/shellspec/shellspec) for tests.

Run all tests from the repository root.

```bash
shellspec
```

Run the public entrypoint integration tests separately.

```bash
shellspec spec/integration/texenv_spec.sh
```

The integration tests exercise `bin/texenv` through version selection, command execution, package freeze and restore, and environment diagnosis.

CI runs ShellSpec on `ubuntu-latest` and `macos-latest`.

Run ShellSpec, `git diff --check`, and ShellCheck before submitting changes.

## 📝 Todo

Planned work is tracked in [GitHub Issues](https://github.com/redpeacock78/texenv/issues).

## 📜 License

texenv is distributed under the MIT License.

See [LICENSE](LICENSE).

### 🧩 Modules

The texenv runtime uses Bash and standard operating-system commands.

`jq` is optional.

ShellSpec is used for development tests.

## 👏 Affected projects

- [TinyTeX](https://yihui.org/tinytex/)
- [TinyTeX Releases](https://github.com/rstudio/tinytex-releases)
- [rbenv](https://github.com/rbenv/rbenv)

texenv is inspired by the TinyTeX distribution format and the rbenv shim model.

## 💕 Special Thanks

Thanks to [ShellSpec](https://github.com/shellspec/shellspec), the developers of TeX Live and TinyTeX, and the maintainers of the tools used by texenv.
