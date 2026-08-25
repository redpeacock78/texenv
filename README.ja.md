<!-- 日本語README -->

<div align="center">

![Last commit](https://img.shields.io/github/last-commit/redpeacock78/texenv?style=flat-square)
![Repository Stars](https://img.shields.io/github/stars/redpeacock78/texenv?style=flat-square)
![Issues](https://img.shields.io/github/issues/redpeacock78/texenv?style=flat-square)
![Open Issues](https://img.shields.io/github/issues-raw/redpeacock78/texenv?style=flat-square)
![Bug Issues](https://img.shields.io/github/issues/redpeacock78/texenv/bug?style=flat-square)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/redpeacock78/texenv)
<br>
<img src="https://www.emoji.family/api/emojis/%F0%9F%93%9D/twemoji/svg" alt="アイキャッチ" height="100">

# 📝 texenv

texenvは、TinyTeX（最小構成のTeX Live）を管理するBash製のバージョンマネージャーです。

複数のTinyTeXリリースをインストールし、プロジェクトごとにTeX Liveのバージョンを選択しながら、shim経由でTeXコマンドを実行できます。

texenvの管理外にあるTeX Liveのインストールは変更しません。

<br>
<br>

</div>

<table>
  <thead>
    <tr>
      <th style="text-align:center">🍡日本語</th>
      <th style="text-align:center"><a href="README.md">🍔English</a></th>
    </tr>
  </thead>
</table>

## 🚀 使い方

### 最短の手順

texenvをcloneして、シェル連携を初期化します。

```bash
git clone https://github.com/redpeacock78/texenv.git "${HOME}/.texenv"
eval "$("${HOME}/.texenv/bin/texenv" init -)"
texenv init
```

TinyTeXをインストールし、global設定を作成してshimを生成します。

```bash
texenv install 2026.04
texenv global 2026.04
texenv rehash
```

プロジェクトで使用するバージョンを選択し、TeXコマンドを実行します。

```bash
texenv local 2026.04
pdflatex main.tex
```

### バージョンを選択する

`global`はデフォルトのバージョンを選択します。

`local`は、現在のプロジェクトディレクトリに`.tex-version`を書き込みます。

texenvは親ディレクトリのlocal設定も探索し、global設定より優先します。

`shell`は現在のシェルだけで使用するバージョンを選択します。

```bash
texenv global 2026.04
texenv local 2026.04
eval "$(texenv shell 2026.04)"
texenv version
texenv versions
```

### TeXコマンドを実行する

現在選択されているバージョンのコマンドを、`exec`から明示的に実行できます。

```bash
texenv exec pdflatex main.tex
texenv exec tlmgr info geometry
```

`rehash`を実行すると、shim経由でTeX実行ファイルを直接実行できます。

```bash
texenv rehash
pdflatex main.tex
```

Perlと`File::Find`の検査は、コマンド実行時にはtexenvが`tlmgr`を実行するときだけ行われます。

`doctor`は、この前提条件を明示的に検査します。

通常のTeXコマンド実行では、この検査を行いません。

### パッケージを固定・復元する

インストール済みパッケージ名を`tex-require.txt`へ保存します。

```bash
texenv freeze
```

TeX Liveの年、プラットフォーム、リポジトリ、パッケージのrevision、リポジトリのmanifestを記録したlockファイルを作成します。

```bash
texenv freeze --lock
```

lockファイルには、各パッケージのインストール済み`localrev`と、対応するリポジトリrevision manifestのハッシュが記録されます。

`restore`は、インストール前にTeX Liveの年、プラットフォーム、リポジトリ、パッケージrevisionを検証します。

```bash
texenv restore
```

インストール済みパッケージのrevisionが異なり、アーカイブもない場合は処理を中止します。

オフライン復元やrevisionのロールバックに使うパッケージアーカイブを、lockファイルと一緒に保存できます。

```bash
texenv freeze --lock --archive
texenv restore
```

アーカイブはプロジェクトディレクトリの`.texenv/cache/`へ保存されます。

アーカイブは`tlmgr restore`の実行前にSHA-512値を検証します。

アーカイブを含む完全なlockファイルからの復元では、TeX Liveリポジトリへ接続する必要がありません。

`--archive`は`--lock`と一緒に指定してください。

`--dry-run`を指定すると、パッケージを変更せずに復元内容を確認できます。

requirementsにない余分なパッケージは削除しません。

### tlmgrのリポジトリを管理する

現在のリポジトリを表示します。

```bash
texenv repo --show
```

選択中のTeX Liveバージョンに使うミラーを指定します。

```bash
texenv repo --mirror https://mirror.example.org/tex-archive/systems/texlive/tlnet
```

リポジトリをデフォルトの自動選択へ戻します。

```bash
texenv repo --reset
```

### コマンドを検索する

`which`はshimのパスを表示します。

`where`は選択中のバージョンにある実行ファイルのパスを表示します。

`whence`はすべてのインストール済みバージョンにある実行ファイルのパスを表示します。

```bash
texenv which pdflatex
texenv where pdflatex
texenv whence pdflatex
```

### 環境を診断する

`doctor`は、現在のバージョン、必要なコマンド、TeXコマンド、`tlmgr`用のPerl、shim、コマンドキャッシュ、パッケージスナップショットを読み取り専用で検査します。

```bash
texenv doctor
texenv env
texenv root
texenv shims
texenv commands
```

## ⬇️ インストール

### 対応プラットフォーム

- macOS（Darwin）
- Linux x86_64
- Linux ARM64（aarch64またはarm64）

対応していないOSまたはアーキテクチャでは、起動時に終了します。

### シェルとコマンド

Bash 4.x以上が必要です。

zshから利用する場合は、シェル設定で`texenv init -`の出力を評価してください。

次のコマンドが必要です。

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
- `sha256sum`、`shasum`、`openssl`のいずれか

`readlink`は任意です。

利用できる場合はシンボリックリンクの解決に使います。

利用できない場合は`ls -dl`へフォールバックします。

`jq`は任意です。

インストールされている場合は、GitHub Releases APIのレスポンス解析に使います。

`jq`がない場合も、texenvは必要なasset情報だけを解析します。

Perlと`File::Find`モジュールは、`tlmgr`を実行するときだけ必要です。

TinyTeXはPerl経由で`tlmgr`を実行するため、通常のTeXコマンド実行ではこの検査を行いません。

詳細は[TinyTeXのドキュメント](https://yihui.org/tinytex/)と[TinyTeX issue #419](https://github.com/rstudio/tinytex/issues/419)を参照してください。

インストールとリポジトリを使う復元には、GitHub Releases API、TinyTeXアーカイブ、TeX Liveリポジトリへ接続できるネットワーク環境が必要です。

### anyenvを使う場合

[anyenv](https://github.com/anyenv/anyenv)を利用している場合は、次のコマンドでtexenvをインストールできます。

```bash
rm -rf "${HOME}/.config/anyenv/anyenv-install"
anyenv install --init https://github.com/redpeacock78/anyenv-install.git texenv-add
anyenv install texenv
```

シェル設定へ次の行を追加します。

```bash
eval "$(anyenv init -)"
```

### Gitからインストールする場合

最短の手順では、Gitリポジトリを`~/.texenv`へcloneします。

シェル設定を読み込んだあと、`texenv init`を実行してください。

TinyTeXのリリースアーカイブは、展開前にGitHub Releases APIが公開するSHA-256ダイジェストで検証されます。

ダイジェストがない場合、一致しない場合、SHA-256を計算できるコマンドがない場合はインストールを中止します。

macOSでは通常`.tgz`、Linuxでは通常`.tar.gz`を使います。

対応するアーカイブがない場合は`.tar.xz`へフォールバックします。

### プロジェクトのファイルとキャッシュ

プロジェクト単位のファイルは、texenvを実行したディレクトリへ保存されます。

```text
project/
├── .tex-version
├── tex-require.txt
├── tex-require.lock
└── .texenv/
    └── cache/
```

`.tex-version`、`tex-require.txt`、`tex-require.lock`はプロジェクトのファイルとしてGitで管理できます。

`.texenv/`は実行時キャッシュのため、デフォルトでGitの対象外です。

`freeze --lock --archive`を指定した場合、キャッシュには`tlmgr backup`が作成したパッケージアーカイブが保存されます。

### ディレクトリ構成

texenvの標準ディレクトリは次の通りです。

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

`versions/`には、展開したTinyTeXのバージョンごとのツリーを保存します。

`shims/`には、選択したバージョンへ処理を渡すshimを保存します。

`config/`には、コマンドキャッシュとバージョンごとのミラー設定を保存します。

`texmf/`はユーザー用の`TEXMF_HOME`として使います。

### texenvを更新・削除する

インストール済みバージョンを削除するには、次のコマンドを実行します。

```bash
texenv uninstall 2026.04
```

現在選択中のバージョンを削除する場合は、先に別のバージョンをglobalまたはlocalへ設定してください。

Gitで管理しているtexenvを更新するには、次のコマンドを実行します。

```bash
cd "${HOME}/.texenv"
git pull --ff-only
texenv rehash
```

texenvを削除する場合は、`${HOME}/.texenv`を削除し、シェル設定から初期化コマンドとtexenvのPATH設定を削除してください。

## ⛏️ 開発

テストには[ShellSpec](https://github.com/shellspec/shellspec)を使います。

リポジトリのルートで全テストを実行してください。

```bash
shellspec
```

公開エントリポイントを通す結合テストだけを実行する場合は、次のコマンドを使います。

```bash
shellspec spec/integration/texenv_spec.sh
```

結合テストでは、`bin/texenv`を通したバージョン選択、コマンド実行、パッケージのfreezeとrestore、環境診断を検証します。

CIでは`ubuntu-latest`と`macos-latest`でShellSpecを実行します。

変更を送る前に、ShellSpec、`git diff --check`、ShellCheckを実行してください。

## 📝 Todo

対応予定の項目は[GitHub Issues](https://github.com/redpeacock78/texenv/issues)で管理します。

## 📜 ライセンス

texenvはMIT Licenseで配布しています。

詳細は[LICENSE](LICENSE)を参照してください。

### 🧩 使用モジュール

texenv本体はBashとOS標準コマンドで動作します。

`jq`は任意です。

ShellSpecは開発時のテストに使います。

## 👏 影響を受けたプロジェクト

- [TinyTeX](https://yihui.org/tinytex/)
- [TinyTeX Releases](https://github.com/rstudio/tinytex-releases)
- [rbenv](https://github.com/rbenv/rbenv)

texenvはTinyTeXの配布形式とrbenvのshim方式を参考にしています。

## 💕 スペシャルサンクス

[ShellSpec](https://github.com/shellspec/shellspec)、TeX LiveとTinyTeXの開発者、texenvが利用するツールのメンテナーに感謝します。
