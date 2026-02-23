# 開発環境ベースイメージ

コンテナ開発環境のベースイメージとして、Git、SSH、GPG などの基本ツールのインストールとセットアップ、認証ファイルのインポート/エクスポート機能を提供します。
プロジェクト固有のツール群は、このベースイメージから派生させた開発コンテナイメージでインストールする設計思想です。

## 特徴

- **基本ツールの自動セットアップ**: Git、SSH、GPG、GitHub CLI、Docker、vim のインストールと設定を自動化
- **認証ファイル管理**: ホストとコンテナ間で Git 設定、SSH 鍵、GPG 鍵のインポート/エクスポートが可能
- **ベースイメージとして設計**: プロジェクト固有のツールは派生イメージで追加する拡張可能な構成
- **開発環境サンプル提供**: Python 開発環境、Node.js 開発環境（VS Code Dev Container）の実装例を同梱

## 基本的な使用方法

### 1. 環境設定

```bash
# .envファイルを作成
cp .env.example .env

# .envファイルを編集してメールアドレスと名前を設定
# GIT_USER_EMAIL=your-email@example.com
# GIT_USER_NAME=Your Full Name
```

### 2. ホストファイルの準備（オプション）

ホストの認証情報をコンテナで使用する場合は以下を参照してください。

<details>
<summary>ホストの Git/SSH/GPG 設定をインポートする手順（クリックして展開）</summary>

コンテナ内でホストのGit設定、SSHキー、GPGキーを使用したい場合は、以下のファイルを`import/`ディレクトリに配置してください。

#### Git 設定

```bash
# ホストのGit設定をコピー
cp ~/.gitconfig import/.gitconfig
```

#### SSH キー

```bash
# ホストのSSHキーをコピー
mkdir -p import/.ssh
cp ~/.ssh/id_* import/.ssh/
chmod 644 import/.ssh/id_*
```

#### GPG キー

```bash
# GPGキーと信頼データベースをエクスポート
mkdir -p import/.gnupg
gpg --armor --export-secret-keys your-email@example.com > import/.gnupg/private-keys.asc
gpg --armor --export your-email@example.com > import/.gnupg/public-keys.asc
gpg --export-ownertrust > import/.gnupg/ownertrust.txt
```

**注意**:

- これらのファイルは機密情報を含むため、`.gitignore`で除外されています
- SSHキーやGPGキーは適切に管理し、不要になったら削除してください

</details>

### 3. ベースイメージのビルドと起動

以下のコマンドから目的に応じて選択、組み合わせて実行してください：

```bash
# 通常のビルド
docker compose build

# イメージを強制的にプルしたい場合
docker compose build --pull

# キャッシュを無効にしてクリーンビルドしたい場合
docker compose build --no-cache

# ビルドのログを詳細表示したい場合
docker compose --progress plain build

# ビルドと起動
docker compose up --build

# バックグラウンドで起動したい場合
docker compose up --build -d
```

### 4. コンテナへの接続

```bash
# コンテナに接続
docker compose exec workspace bash
```

### 5. 設定のエクスポート（オプション）

コンテナで生成した認証情報をホストで使用する場合は以下を参照してください。

<details>
<summary>Git/SSH/GPG 設定をホストへエクスポートする手順（クリックして展開）</summary>

コンテナ内で使用されているGit、SSH、GPGの設定を`export/`ディレクトリにエクスポートできます。ホスト側でも同じ設定（Git設定、SSH接続、GPG署名など）を利用したい場合に、以下の手順を参考にしてください。

#### エクスポートされる設定

- **Git設定**: `.gitconfig`が`export/`ディレクトリにエクスポート
- **SSH設定**: SSH鍵とconfigが`export/.ssh/`にエクスポート
- **GPG設定**: GPG鍵と信頼設定が`export/.gnupg/`にエクスポート

#### エクスポートの実行

```bash
# バックグラウンドで起動
docker compose up -d

# エクスポートスクリプトを実行
docker compose exec workspace bash /export/scripts/export-settings.sh
```

#### ホストへの設定コピー

エクスポートされた設定をホスト側で使用したい場合は、以下のコマンドでコピーできます。

##### Git設定のコピー

```bash
# Git設定をホストにコピー
cp export/.gitconfig ~/.gitconfig
```

##### SSH設定のコピー

```bash
# SSH設定をホストにコピー
cp -r export/.ssh/* ~/.ssh/
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub
```

##### GPG設定のインポート

```bash
# GPG鍵をホストにインポート
gpg --import export/.gnupg/private-key-*.asc
gpg --import export/.gnupg/public-key-*.asc
gpg --import-ownertrust export/.gnupg/ownertrust-*.txt
```

**注意**:

- エクスポートされたファイルには機密情報が含まれるため、適切に管理してください
- これらのファイルは`.gitignore`で除外されています

</details>

## 含まれるツール

このベースイメージには以下のツールがプリインストールされています。各ツールのセットアップは `scripts/` ディレクトリのスクリプトで管理されています。

### インストール済みツール一覧

- **vim** - テキストエディタ
- **SSH** - OpenSSH クライアント、鍵生成/インポート機能
- **GPG** - GnuPG、鍵生成/インポート機能
- **Git** - Git + Git LFS、自動設定、GPG 署名対応
- **GitHub CLI** - `gh` コマンド
- **Docker** - Docker Engine + Buildx + Compose プラグイン

### ベースイメージの拡張

このベースイメージは、プロジェクト固有のツールをインストールするための土台として設計されています。
派生イメージを作成する場合は、以下のように `FROM` でこのイメージを指定し、必要なツールを追加してください。

```dockerfile
FROM devcontainer-baseimage:latest

# プロジェクト固有のツールをインストール
RUN apt-get update && apt-get install -y \
    nodejs \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# 追加の設定やツールのセットアップ
# ...
```

既存のセットアップスクリプトをカスタマイズする場合は、`scripts/` ディレクトリ内の該当スクリプトを直接編集してください。
