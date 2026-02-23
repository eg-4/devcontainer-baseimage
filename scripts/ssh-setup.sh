#!/bin/bash

# SSH セットアップスクリプト
# 概要: SSHキーの生成またはホストからのコピーを行います

set -euo pipefail

echo "🚀 === SSH セットアップ開始 ==="

# 必要なパッケージのインストール
echo "必要なパッケージをインストール中..."
sudo apt-get install -qq -y \
  openssh-client \
  rsync

# SSHディレクトリの初期設定
echo "SSHディレクトリを初期化中..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# ホストのSSH秘密鍵をチェックしてコピー
if [ -d "/tmp/import/.ssh" ] && [ "$(find /tmp/import/.ssh -type f -name 'id_*' ! -name '*.pub' 2>/dev/null | wc -l)" -gt 0 ]; then
  echo "ホストSSHキーをコピー中..."
  rsync --delete -aqz --no-perms /tmp/import/.ssh/ ~/.ssh/

  echo "パーミッションを設定中..."
  # 一旦関連する鍵をすべて600にし、公開鍵のみ644で上書きする
  chmod 600 ~/.ssh/id_*
  chmod 644 ~/.ssh/*.pub

  echo "✅ ホストSSHキーのコピーが完了しました"
else
  echo "SSHキーを生成中..."
  echo "SSHキー用メール: $GIT_USER_EMAIL"
  echo "SSHキーを生成中..."
  ssh-keygen -t ed25519 -C "$GIT_USER_EMAIL" -f ~/.ssh/id_ed25519 -N "" -q
  ssh-keygen -t rsa-sha2-512 -b 4096 -C "$GIT_USER_EMAIL" -f ~/.ssh/id_rsa -N "" -q

  echo "✅ SSHキーの生成が完了しました"
fi

echo "🎉 === SSH セットアップ完了 ==="
