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

# texenv

texenvは、TinyTeX（最小構成のTeX Live）を複数バージョン管理するBash製のバージョンマネージャーです。

プロジェクトごとのTeX Liveバージョンを選択し、shimを通して`pdflatex`や`tlmgr`などを実行できます。

システムにインストールされたTeX Liveには変更を加えません。

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

<div align="center">

</div>

## 🚀 使い方

### 最短の手順

インストール後、シェル設定へ初期化コマンドを追加します。

```bash
eval "$("${HOME}/.texenv/bin/texenv" init -)"
```

初期化後は、バージョンをインストールしてglobal設定を作成します。

```bash
texenv install 2026.04
texenv global 2026.04
texenv rehash
```

プロジェクトごとにバージョンを固定する場合は、プロジェクトのディレクトリでlocal設定を作成します。

```bash
texenv local 2026.04
```

設定したバージョンのTeXコマンドを実行します。

```bash
pdflatex main.tex
```

### 管理できる内容

- TinyTeXのリリース版とdaily版を複数管理できます。
- global設定とプロジェクト単位のlocal設定を使い分けられます。
- TeX Liveのbinディレクトリにある実行可能ファイルからshimを生成できます。
- `tlmgr`の実行前に、TeX Liveの年に対応したリポジトリを選択できます。
- インストール済みパッケージをrequirementsファイルへ保存できます。
- requirementsファイルから不足パッケージを復元できます。
- archiveのSHA-256 digestを検証してからTinyTeXを展開します。

### バージョンを選択する

global設定は、local設定がないディレクトリで使用されます。

```bash
texenv global 2026.04
```

local設定は、現在のディレクトリに`.tex-version`を書き込みます。

親ディレクトリにあるlocal設定も探索され、global設定より優先されます。

```bash
texenv local 2026.04
```

現在のシェルだけで使用するバージョンを設定するには、出力されたシェルコードを評価します。

```bash
eval "$(texenv shell 2026.04)"
```

インストール済みバージョンと現在の選択状態は、次のコマンドで確認できます。

```bash
texenv versions
texenv version
```

### TeXコマンドを実行する

現在選択されているバージョンのコマンドを、`texenv exec`から実行できます。

```bash
texenv exec pdflatex main.tex
texenv exec tlmgr info geometry
```

shimを生成したあとなら、`pdflatex`のようにコマンドを直接実行できます。

```bash
texenv rehash
pdflatex main.tex
```

`tlmgr`のinstall、update、uninstall、remove後には、必要に応じてshimを再生成します。

### shimとコマンドを検索する

shimの場所は`which`で確認できます。

```bash
texenv which pdflatex
```

現在選択されているバージョンの実体は`where`で確認できます。

```bash
texenv where pdflatex
```

すべてのインストール済みバージョンにある同名コマンドは`whence`で確認できます。

```bash
texenv whence pdflatex
```

同じコマンドが複数バージョンに存在する場合も、`whence`は各バージョンのパスを表示します。

### tlmgrリポジトリを管理する

現在のリポジトリを表示します。

```bash
texenv repo --show
```

リポジトリをバージョン単位で指定できます。

```bash
texenv repo --mirror https://mirror.example.org/tex-archive/systems/texlive/tlnet
```

設定を自動選択へ戻します。

```bash
texenv repo --reset
```

TeX Liveが当年版なら最新の`tlnet`を使い、それ以前の年なら対応する`tlnet-final`を使います。

### パッケージを固定・復元する

現在インストールされているパッケージ名を保存します。

```bash
texenv freeze
```

TeX Liveの年も記録したlockファイルを作成するには`--lock`を指定します。

```bash
texenv freeze --lock
```

生成されるファイルは`tex-require.txt`と`tex-require.lock`です。

requirementsファイルにある未インストールのパッケージを追加します。

```bash
texenv restore
```

lockファイルと通常のrequirementsファイルが両方ある場合は、lockファイルを優先します。

現在のTeX Liveがlockファイルに記録された年より古い場合は、互換性保護のため処理を中止します。

requirementsにない余分なパッケージは削除しません。

### 環境を確認する

```bash
texenv env
texenv root
texenv shims
texenv commands
```

`env`は現在のバージョン、TeXの検索パス、リポジトリ、texenv関連のPATHを表示します。

`root`はtexenvの管理ディレクトリを表示します。

`shims`は生成済みshimを表示します。

`commands`は利用可能なサブコマンドを表示します。

### ディレクトリ構成

初期化後の標準構成は次の通りです。

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

`shims/`には、現在選択したバージョンへ処理を渡すshimを保存します。

`config/`にはコマンド一覧のキャッシュと、バージョンごとのmirror設定を保存します。

`texmf/`はユーザー用の`TEXMF_HOME`として使用します。

### バージョンを削除する

```bash
texenv uninstall 2026.04
```

現在選択しているバージョンを削除する場合は、先に別のバージョンをglobalまたはlocalへ設定してください。

### texenvを更新する

```bash
cd "${HOME}/.texenv"
git pull --ff-only
texenv rehash
```

### texenvを削除する

次の作業を行います。

1. `${HOME}/.texenv`を削除します。
2. シェル設定からtexenvの初期化行を削除します。
3. `${HOME}/.texenv/bin`と`${HOME}/.texenv/shims`へのPATH設定を削除します。

## ⬇️ インストール

### 対応OS

- macOS（Darwin）
- Linux x86_64
- Linux ARM64（aarch64またはarm64）

上記以外のOSとアーキテクチャでは起動時にエラーになります。

### シェルとコマンド

Bash 4.x以上が必要です。

zshから利用する場合は、`texenv init -`の出力をシェル設定へ読み込んでください。

次のコマンドを用意してください。

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

利用できる場合はシンボリックリンクの解決に使用し、利用できない場合は`ls -dl`へ代替処理します。

`jq`がインストールされている場合は、GitHub Releases APIのJSON解析に使用します。

`jq`がない環境では、texenvが必要なasset情報だけを解析します。

`tlmgr`を実行するときだけ、Perlと`File::Find`モジュールも必要です。

これはTinyTeXが`tlmgr`をPerl経由で実行するためであり、通常のTeXコマンド実行時には検査しません。

詳細は[TinyTeXの公式ドキュメント](https://yihui.org/tinytex/)と[TinyTeX issue #419](https://github.com/rstudio/tinytex/issues/419)を参照してください。

ネットワーク経由でGitHub Releases API、TinyTeXのarchive、TeX Liveのリポジトリへ接続できる必要があります。

### anyenvを使う場合

[anyenv](https://github.com/anyenv/anyenv)を利用している場合は、次の手順でインストールできます。

```bash
rm -rf "${HOME}/.config/anyenv/anyenv-install"
anyenv install --init https://github.com/redpeacock78/anyenv-install.git texenv-add
anyenv install texenv
```

シェル設定へ次の行を追加します。

```bash
eval "$(anyenv init -)"
```

### Gitから直接インストールする場合

リポジトリを`~/.texenv`へcloneします。

```bash
git clone https://github.com/redpeacock78/texenv.git "${HOME}/.texenv"
```

シェル設定へ次の行を追加します。

```bash
eval "$("${HOME}/.texenv/bin/texenv" init -)"
```

設定を読み込んだあと、`texenv init`が必要なディレクトリを作成します。

```bash
texenv init
```

### archive checksumを検証する

texenvは、選択したTinyTeX archiveに対応するGitHub Releases APIのasset情報からSHA-256 digestを取得します。

archiveを展開する前に、ローカルで計算したSHA-256値とdigestを比較します。

digestが公開されていない場合、digestが一致しない場合、SHA-256を計算できるコマンドがない場合はインストールを中止します。

GitHubがdigestを追加する前に公開された古いTinyTeX releaseには、digestが存在しない場合があります。

そのreleaseを検証なしでインストールする動作は提供していません。

macOSでは通常`.tgz`、Linuxでは通常`.tar.gz`を使用します。

対応するarchiveが見つからない場合は、`.tar.xz`形式へ切り替えます。

### 開発環境で使うBash

macOSの標準Bashが古い場合は、Bash 4.x以上をPATHの先頭へ配置してください。

## ⛏️ 開発

テストには[ShellSpec](https://github.com/shellspec/shellspec)を使います。

リポジトリのルートで次のコマンドを実行してください。

```bash
shellspec
```

CIでは`ubuntu-latest`と`macos-latest`でshellspecを実行します。

変更を送る前に、shellspecと`git diff --check`を実行してください。

## 📝 Todo

対応予定の項目はIssueで管理します。

## 📜 ライセンス

MIT Licenseです。

詳細は[LICENSE](LICENSE)を参照してください。

### 🧩 使用モジュール

texenv本体はBashとOS標準コマンドで動作します。

`jq`は任意です。

ShellSpecは開発時のテストに使用します。

## 👏 影響を受けたプロジェクト

- [TinyTeX](https://yihui.org/tinytex/)
- [TinyTeX Releases](https://github.com/rstudio/tinytex-releases)
- [rbenv](https://github.com/rbenv/rbenv)

texenvは、TinyTeXの配布形式とrbenvのshim方式を参考にしています。

## 💕 スペシャルサンクス

[ShellSpec](https://github.com/shellspec/shellspec)と、TeX LiveおよびTinyTeXの開発者に感謝します。
