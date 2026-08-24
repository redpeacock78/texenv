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

texenv lets you select a TeX Live version per project and run commands such as `pdflatex` and `tlmgr` through shims.

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

<div align="center">

</div>

## 🚀 How to use

### Quick start

After installation, add the initialization command to your shell configuration.

```bash
eval "$("${HOME}/.texenv/bin/texenv" init -)"
```

Install a TinyTeX release, choose the global version, and rebuild the shims.

```bash
texenv install 2026.04
texenv global 2026.04
texenv rehash
```

To pin a version to a project, run `texenv local` in that project directory.

```bash
texenv local 2026.04
```

Run a TeX command through the selected version.

```bash
pdflatex main.tex
```

### What texenv manages

- Multiple TinyTeX release versions and the daily build.
- Global, local, and shell-specific TeX Live version selection.
- Shims for executable files in TeX Live `bin` directories.
- TeX Live year-specific repositories for `tlmgr`.
- Package snapshots in requirements and lock files.
- SHA-256 verification of TinyTeX archives before extraction.

### Selecting a version

A global version is used when no local version applies.

```bash
texenv global 2026.04
```

A local version writes `.tex-version` in the current directory.

texenv also searches parent directories for a local version, which takes precedence over the global version.

```bash
texenv local 2026.04
```

To select a version only for the current shell, evaluate the generated shell code.

```bash
eval "$(texenv shell 2026.04)"
```

Use the following commands to inspect installed versions and the current selection.

```bash
texenv versions
texenv version
```

### Running TeX commands

Run a command through the currently selected version with `texenv exec`.

```bash
texenv exec pdflatex main.tex
texenv exec tlmgr info geometry
```

After rebuilding the shims, commands can be invoked directly.

```bash
texenv rehash
pdflatex main.tex
```

Rebuild the shims after `tlmgr` installs, updates, uninstalls, or removes packages when necessary.

### Finding commands

Use `which` to find a shim.

```bash
texenv which pdflatex
```

Use `where` to find the executable in the selected version.

```bash
texenv where pdflatex
```

Use `whence` to list the executable in every installed version.

```bash
texenv whence pdflatex
```

When the same command exists in multiple versions, `whence` reports every matching path.

### Managing the tlmgr repository

Show the current repository.

```bash
texenv repo --show
```

Set a per-version mirror.

```bash
texenv repo --mirror https://mirror.example.org/tex-archive/systems/texlive/tlnet
```

Return to automatic repository selection.

```bash
texenv repo --reset
```

The current TeX Live year uses the latest `tlnet` repository.

Older TeX Live years use the corresponding `tlnet-final` repository.

### Freezing and restoring packages

Save the names of installed packages.

```bash
texenv freeze
```

Use `--lock` to include the TeX Live year in a lock file.

```bash
texenv freeze --lock
```

The generated files are `tex-require.txt` and `tex-require.lock`.

Restore packages that are listed but not installed.

```bash
texenv restore
```

If both files exist, texenv uses the lock file first.

Restore stops when the current TeX Live year is older than the year recorded in the lock file.

Restore does not remove packages that are not listed in the requirements file.

### Inspecting the environment

```bash
texenv env
texenv root
texenv shims
texenv commands
```

`env` displays the current version, TeX search paths, repository, and texenv-related PATH entries.

`root` displays the texenv root directory.

`shims` displays generated shims.

`commands` displays available subcommands.

### Directory layout

The default layout after initialization is:

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

## ⬇️ Install

### Supported platforms

- macOS（Darwin）
- Linux x86_64
- Linux ARM64（aarch64 or arm64）

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

Network access to the GitHub Releases API, TinyTeX archives, and TeX Live repositories is required.

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

Clone the repository to `~/.texenv`.

```bash
git clone https://github.com/redpeacock78/texenv.git "${HOME}/.texenv"
```

Add the following line to your shell configuration.

```bash
eval "$("${HOME}/.texenv/bin/texenv" init -)"
```

Run `texenv init` after loading the shell configuration.

```bash
texenv init
```

### Archive checksum verification

texenv obtains the SHA-256 digest for the selected TinyTeX archive from the corresponding GitHub Releases API asset.

It compares the digest with the SHA-256 hash calculated locally before extracting the archive.

Installation stops when the digest is missing, does not match, or no SHA-256 command is available.

Older TinyTeX releases published before GitHub added asset digests may not have a digest.

texenv does not provide an unverified installation path for those releases.

macOS normally uses `.tgz` archives, while Linux normally uses `.tar.gz` archives.

If the corresponding archive is unavailable, texenv falls back to `.tar.xz`.

### Bash for development

The Bash bundled with macOS may be older than 4.x.

Put Bash 4.x or later first in `PATH` when developing on macOS.

## ⛏️ Development

Use [ShellSpec](https://github.com/shellspec/shellspec) for tests.

Run the following command from the repository root.

```bash
shellspec
```

CI runs ShellSpec on `ubuntu-latest` and `macos-latest`.

Run ShellSpec and `git diff --check` before submitting changes.

## 📝 Todo

Planned work is tracked in GitHub Issues.

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

Thanks to [ShellSpec](https://github.com/shellspec/shellspec) and the developers of TeX Live and TinyTeX.
