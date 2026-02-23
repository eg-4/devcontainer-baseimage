#!/bin/bash

# GitHub CLI セットアップスクリプト
# 概要: GitHub CLI (gh) の最新版をUbuntuにインストールします

set -euo pipefail

echo "🚀 === GitHub CLI セットアップ開始 ==="

# 必要なパッケージのインストール
echo "必要なパッケージをインストール中..."
sudo apt-get install -qq -y \
  wget \
  curl

# GitHub CLI のインストール（公式手順準拠）
# https://github.com/cli/cli/blob/trunk/docs/install_linux.md
echo "GitHub CLI GPGキーをセットアップ中..."
sudo mkdir -p -m 755 /etc/apt/keyrings
out=$(mktemp)
wget -nv -O"$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg
cat "$out" | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
sudo mkdir -p -m 755 /etc/apt/sources.list.d
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

echo "GitHub CLI をインストール中..."
sudo apt-get update -qq
sudo apt-get install -qq -y gh

# インストール確認
if command -v gh &> /dev/null; then
  echo "✅ GitHub CLI のインストールが完了しました:"
  gh --version
else
  echo "❌ GitHub CLI のインストールに失敗しました"
  exit 1
fi

echo "🎉 === GitHub CLI セットアップ完了 ==="
