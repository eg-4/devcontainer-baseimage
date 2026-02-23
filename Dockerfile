# syntax=docker/dockerfile:1

# ============================================
# Stage 1: base
# 共通基盤（sudo インストール、タイムゾーン・ロケール設定）
# ============================================
FROM ubuntu:24.04 AS base

ENV TZ=Asia/Tokyo

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# タイムゾーンとロケールの設定
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
  <<EOF
export DEBIAN_FRONTEND=noninteractive

apt-get update -qq
apt-get install -qq -y \
  locales \
  sudo \
  tzdata

# ロケールのセットアップ
locale-gen ja_JP.UTF-8

# 不要なパッケージを削除
apt-get autoremove -y

EOF

# ロケール環境変数の設定
ENV LANG=ja_JP.UTF-8

# ============================================
# Stage 2: user_setup
# Non-root ユーザー（ubuntu）のsudo設定
# ============================================
FROM base AS user_setup

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

RUN <<EOF
echo -e "\n\033[1;45;97m▓▓▓ ubuntu ユーザー設定 ▓▓▓\033[0m\n"

# ubuntuユーザーを sudo グループに追加
usermod -a -G sudo ubuntu
echo "✅ ubuntu ユーザーを sudo グループに追加しました"

# sudo パスワード無し実行を許可
mkdir -p /etc/sudoers.d
echo "ubuntu ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ubuntu
chmod 0440 /etc/sudoers.d/ubuntu

echo -e "\n✅ ubuntu ユーザーのセットアップが完了しました\n"
EOF

USER ubuntu

# ============================================
# Stage 3: custom_install
# パッケージの個別カスタマイズインストール
# ============================================
FROM user_setup AS custom_install

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# メールアドレスと名前をARGで受け取る
ARG GIT_USER_EMAIL
ARG GIT_USER_NAME

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
  --mount=type=tmpfs,target=/tmp \
  --mount=target=/tmp/scripts,source=scripts \
  --mount=target=/tmp/import,source=import \
  <<EOF
echo -e "\n\033[1;44;97m▓▓▓ 開発環境セットアップ開始 ▓▓▓\033[0m\n"

sudo apt-get update -qq

# ビルド引数のバリデーション
bash /tmp/scripts/validate-args.sh

echo -e "\n\033[1;46;30m▓▓▓ 各種ツールのインストールと設定 ▓▓▓\033[0m\n"
# 以降のインストールは、コメントアウトやスクリプトの追加・変更など、必要に応じてカスタマイズしてください。

# vim のインストール
bash /tmp/scripts/install-vim.sh

# SSHのセットアップ
bash /tmp/scripts/ssh-setup.sh

# GPGのセットアップ
bash /tmp/scripts/gpg-setup.sh

# Gitのインストール
bash /tmp/scripts/git-setup.sh

# GitHub CLIのインストール
bash /tmp/scripts/github-cli-setup.sh

# Dockerのインストール
bash /tmp/scripts/docker-setup.sh

# 不要なパッケージを削除
sudo apt-get autoremove -y

echo -e "\n\033[1;42;30m▓▓▓ セットアップ完了 ▓▓▓\033[0m\n"

EOF
