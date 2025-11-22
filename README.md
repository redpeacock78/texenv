# texenv
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/redpeacock78/texenv)  

A lightweight version manager for TinyTeX (minimal TeX Live) inspired by rbenv. It lets you install multiple TinyTeX releases side‑by‑side, select global or per‑project versions, expose TeX executables through shims, and freeze / restore package sets.

## Features

- Install specific TinyTeX release versions (including a rolling daily build).
- Maintain multiple versions concurrently under $HOME/.texenv/versions
- Set a global default or per‑directory local version via .tex-version
- Automatic shim regeneration after package changes
- Execute tlmgr and other TeX tools inside the currently selected version
- Freeze installed package names to tex-require.txt or lock with TeX Live version in tex-require.lock
- Restore packages from a requirements file
- Pure Bash implementation; see Requirements
- No modification of system TeX installations

## Requirements

- Operating systems:
  - macOS (Darwin): platform "universal-darwin", archives ".tgz"
  - Linux x86_64: platform "x86_64-linux", archives ".tar.gz"
  - Others are not supported (texenv exits with "unsupported OS").
- Shell:
  - Bash >= 4.x
  - zsh users can eval the init snippet in their shell profile.
  - POSIX sh is not supported.
- Tools:
  - curl
  - perl with File::Find module (validated at startup)
  - tar
  - find, grep, awk, tr, cat, mkdir
- Network:
  - Internet access to GitHub Releases and API (for version list and archives)

## Installation

Clone the repository somewhere on your PATH (recommended: $HOME/.texenv):

```bash
git clone https://github.com/redpeacock78/texenv.git ~/.texenv
```

Add texenv initialization lines to your shell profile (~/.bashrc, ~/.zshrc, etc.):

```bash
eval "$(~/.texenv/bin/texenv init -)"
```

Open a new shell (or source your profile) then run:

```bash
texenv init
```

This will create the directory structure:

```text
~/.texenv/
  bin/texenv
  shims/
  versions/
  config/
  texmf/
  version
```

Ensure ~/.texenv/bin and ~/.texenv/shims appear early in PATH (the init - output adds them).

## Upgrading texenv

Pull the latest changes:

```bash
cd ~/.texenv
git pull --ff-only
texenv rehash
```

## Installing TinyTeX versions

List available versions (queried from tinytex-releases):

```bash
texenv install --list
```

Install a specific version:

```bash
texenv install 2024.09
```

Install / refresh the daily build:

```bash
texenv install daily
```

Force reinstall an already installed version:

```bash
texenv install --force 2024.09
```

## Listing installed versions

```bash
texenv versions
```

Output marks the active one with an asterisk and indicates which file set it (global version or a local .tex-version).

## Selecting the active version

Set the global default:

```bash
texenv global 2024.09
```

Set a project‑local version (writes .tex-version in the current directory):

```bash
texenv local 2024.11
```

Check the current version:

```bash
texenv version
```

## Executing TeX commands

Use texenv exec to run any TeX program inside the active version:

```bash
texenv exec pdflatex main.tex
texenv exec tlmgr info geometry
```

Shims let you call commands directly (e.g. pdflatex) after rehash has generated them. When ambiguous, texenv ensures the correct version by resolving TinyTeX-Version and path metadata.

## Rehashing shims

After installs, removals, or tlmgr operations that change available binaries:

```bash
texenv rehash
```

## Freezing packages

Generate a requirements file of currently installed packages:

```bash
texenv freeze
```

Create a lock file including the TeX Live version:

```bash
texenv freeze --lock
```

Files produced:

- tex-require.txt
- tex-require.lock (first line comment holds TeX Live release)

## Restoring packages

Restore from whichever requirements file exists (prefers lock):

```bash
texenv restore
```

If the lock file specifies a newer TeX Live version than the active one, restore aborts to protect compatibility.

## Inspecting environment

```bash
texenv env
```

Shows:

- Active TinyTeX version
- TEXMF path variables (kpsewhich resolution)
- Active configured repositories
- texenv-related PATH entries
- Installed versions summary

## Executing tlmgr safely

texenv exec tlmgr install <pkg> will:

1. Ensure repository configuration (texenv repo) if needed for install/update/search/info operations.
2. Run tlmgr in the active version context.
3. Rebuild shims after operations that add or remove binaries.

## Uninstalling a version

```bash
texenv uninstall 2024.09
```

## How version resolution works

- Local .tex-version in the current or parent directories overrides global version.
- Global version stored in ~/.texenv/version used when no local file found.
- resolveVersion outputs both TinyTeX-Version and TinyTeX-Path for other commands.

## Directory layout

- versions/<ver> contains the extracted TinyTeX tree (bin/<platform>/... etc.)
- shims/<cmd> are small Bash launchers pointing back to bin/texenv exec
- texmf/ is assigned to TEXMFHOME for user-level additions
- config/ stores internal caches (e.g. cmd_list_cache.txt)

## Environment variables

- TEXENV_ROOT (default: $HOME/.texenv)
- TEXENV_PLATFORM (detected: universal-darwin or x86_64-linux)
- TEXENV_DEBUG=1 enables shell tracing
- TEXMFHOME overridden to texenv’s managed texmf directory

## Removing texenv

1. Delete ~/.texenv
2. Remove initialization lines from your shell profile
3. Remove PATH entries referencing ~/.texenv/bin and ~/.texenv/shims

## Contributing

- Open issues for bugs or enhancement ideas.
- Submit pull requests with concise commits and description.
- Keep code POSIX/Bash compatible; avoid external dependencies.

## License

MIT License. See LICENSE file.

## Disclaimer

texenv manages TinyTeX distributions non-destructively. It does not replace full TeX Live installations; for advanced scenarios (custom schemes, system-wide install) use official TeX Live tools directly.
