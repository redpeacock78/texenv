# texenv
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/redpeacock78/texenv)  

A lightweight version manager for TinyTeX (minimal TeX Live) inspired by rbenv. It lets you install multiple TinyTeX releases side‑by‑side, select global or per‑project versions, expose TeX executables through shims, and freeze / restore package sets.

## Features

- Install specific TinyTeX release versions (including a rolling daily build).
- Maintain multiple versions concurrently under $HOME/.texenv/versions
- Set a global default or per‑directory local version via .tex-version
- Shims for TeX commands; automatic shim regeneration after tlmgr installs/updates/removals and explicit rehash command
- Execute tlmgr and other TeX tools inside the currently selected version
- Freeze installed package names to tex-require.txt or lock with TeX Live version in tex-require.lock
- Restore installs any missing packages from a requirements file (does not remove extras)
- Repository management for tlmgr:
  - Auto-selects an appropriate repository based on TeX Live year (latest tlnet for current year, historic tlnet-final for past years)
  - Show current repository and set per-version mirror overrides
- Spawn a shell scoped to a specific TinyTeX version
- Introspection helpers: which/where/whence, root, shims
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
  - find, grep, awk, diff, cat, mkdir, uname, sort, rm
- Network:
  - Internet access to GitHub Releases and API (for version list and archives)

## Installation

### Using anyenv (Recommended)

If you have [anyenv](https://github.com/anyenv/anyenv) installed, you can easily install texenv:

```bash
rm -rf "${HOME}/.config/anyenv/anyenv-install"
anyenv install --init https://github.com/redpeacock78/anyenv-install.git texenv-add
anyenv install texenv
```

Add texenv initialization lines to your shell profile (~/.bashrc, ~/.zshrc, etc.):

```bash
eval "$(anyenv init -)"
```

### Manual Installation

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

### Directory Structure

After installation, the following directory structure will be created:

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

## Command overview

Matches `texenv help`:

- commands            List available commands
- init                Initialize texenv environment
- install [version]   Install specified TinyTeX version
- uninstall [version] Uninstall specified TinyTeX version
- version             Show current TinyTeX version
- versions            List installed TinyTeX versions
- shell [version]     Spawn a new shell with specified TinyTeX version
- global [version]    Set global TinyTeX version
- local [version]     Set local TinyTeX version
- repo [options]      Manage tlmgr repository
- exec [cmd] [args]   Execute command in current TinyTeX version
- rehash              Rebuild shims for installed TinyTeX versions
- freeze [options]    Freeze installed TeX packages to requirements file
- restore             Restore TeX packages from requirements file
- which [cmd]         Show path to shim for specified command
- where [cmd]         Show path to command in current TinyTeX version
- whence [cmd]        Show path to command in all installed TinyTeX versions
- env                 Display texenv environment information
- root                Show texenv root directory
- shims               Show executable file(s) from texenv shims directory
- help                Show this help message

## Upgrading texenv

```bash
cd ~/.texenv
git pull --ff-only
texenv rehash
```

## Installing TinyTeX versions

List available versions (queried from tinytex-releases):

```bash
texenv install --list
# show more (paginated by API): 
texenv install --list --all
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

Behavior with tlmgr:
- Before tlmgr install/update/info/search, texenv ensures repository configuration (`texenv repo`).
- After tlmgr install/update/uninstall/remove, shims are regenerated (`texenv rehash` invoked).

Shims let you call commands directly (e.g. `pdflatex`) once generated. texenv resolves the correct version via TinyTeX-Version and source metadata.

## Rehashing shims

After installs, removals, or tlmgr operations that change available binaries:

```bash
texenv rehash
```

## Repository management (tlmgr)

Show current repository:

```bash
texenv repo -s
```

Auto-selection (default):
- If TeX Live year equals the current year, uses the latest tlnet:
  - https://ctan.math.illinois.edu/systems/texlive/tlnet
- Otherwise uses the historic archive for that year:
  - https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/[YEAR]/tlnet-final

Set a per-version mirror override (persisted):

```bash
texenv repo -m https://mirror.example.org/tex-archive/systems/texlive/tlnet
```

Mirror overrides are stored at:

- config/[version]/mirror_repo.txt

If the requested repository matches the current setting, the command is a no-op.

## Freezing packages

Generate a requirements file of currently installed packages:

```bash
texenv freeze
```

Create a lock file including the TeX Live version (first line comment):

```bash
texenv freeze --lock
# file header example:
# TeX Live: 2024
```

Files produced:

- tex-require.txt
- tex-require.lock

## Restoring packages

Restore from whichever requirements file exists (prefers lock):

```bash
texenv restore
```

Notes:
- Installs packages that are listed but not currently installed.
- Does not remove extra packages.
- If the lock file requires a newer TeX Live than the active one, restore aborts to protect compatibility.

## Inspecting environment

```bash
texenv env
```

Shows:

- Active TinyTeX version
- TEXMF path variables (via kpsewhich)
- Active configured repositories
- texenv-related PATH entries
- Installed versions summary

## Shell-scoped version

Spawn a new subshell with a specified version (exports TEXENV_VERSION for the shell):

```bash
eval "$(texenv shell 2024.09)"
```

If no version is provided and no shell-specific version is set, it reports the state.

## Uninstalling a version

```bash
texenv uninstall 2024.09
```

## How version resolution works

- Local .tex-version in the current or parent directories overrides global version.
- Global version stored in ~/.texenv/version used when no local file found.
- resolveVersion outputs both TinyTeX-Version and TinyTeX-Path (for shell-scoped versions, the path indicates the shell origin).

## Directory layout

- versions/[ver] contains the extracted TinyTeX tree (bin/[platform]/... etc.)
- shims/[cmd] are small Bash launchers pointing back to bin/texenv exec
- texmf/ is assigned to TEXMFHOME for user-level additions
- config/ stores internal data:
  - cmd_list_cache.txt
  - [version]/mirror_repo.txt

## Environment variables

- TEXENV_ROOT (default: $HOME/.texenv)
- TEXENV_DIR (defaults to current working directory, used for local version resolution)
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
- Keep code Bash-compatible; avoid external dependencies.

## License

MIT License. See LICENSE file.

## Disclaimer

texenv manages TinyTeX distributions non-destructively. It does not replace full TeX Live installations; for advanced scenarios (custom schemes, system-wide install) use official TeX Live tools directly.
