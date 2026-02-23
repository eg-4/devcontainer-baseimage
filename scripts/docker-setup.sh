#!/bin/bash

# Docker Engine セットアップスクリプト
# 概要: Ubuntuに公式リポジトリからDocker Engine最新版(stable)をインストールします。
# 参考: https://docs.docker.com/engine/install/ubuntu/

set -euo pipefail

echo "🚀 === Docker Engine セットアップ開始 ==="

echo "🧹 旧バージョン/競合パッケージの削除中..."
sudo apt-get remove -qq -y \
  docker.io \
  docker-doc \
  docker-compose \
  docker-compose-v2 \
  podman-docker \
  containerd \
  runc \
  2>/dev/null || true

sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd

sudo rm -f /etc/apt/sources.list.d/docker.sources
sudo rm -f /etc/apt/keyrings/docker.asc

echo "📦 事前必要パッケージをインストール中..."
sudo apt-get install -qq -y \
  ca-certificates \
  curl

echo "🔐 GPGキー格納ディレクトリの準備中..."
sudo install -m 0755 -d /etc/apt/keyrings

echo "🔑 Docker公式GPGキーを取得中..."
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# shellcheck source=/dev/null
sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

echo "🔄 パッケージインデックス更新中..."
sudo apt-get update -qq

echo "🐳 Docker Engine関連パッケージをインストール中..."
sudo apt-get install -qq -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

echo "🧪 インストール検証中..."
if command -v docker &> /dev/null; then
  echo "✅ docker コマンド検出: $(command -v docker)"
  docker --version
  echo "🔧 Buildx プラグイン確認:"; docker buildx version || echo "⚠️ buildx 未確認"
  echo "🧩 compose プラグイン確認:"; docker compose version || echo "⚠️ compose 未確認"
else
  echo "❌ docker コマンドが見つかりません。インストールに失敗しました。"
  exit 1
fi

# 実行中のユーザーを docker グループに追加
# 注: Docker build中はUSER環境変数が未設定のため、whoamiを使用
TARGET_USER="${USER:-$(whoami)}"

echo "👤 $TARGET_USER ユーザーを docker グループに追加中..."
if ! id -u "$TARGET_USER" > /dev/null 2>&1; then
  echo "❌ $TARGET_USER ユーザーが見つかりません。"
  exit 1
fi
if ! getent group docker > /dev/null 2>&1; then
  echo "❌ docker グループが見つかりません。"
  exit 1
fi
if id -nG "$TARGET_USER" | grep -qw "docker"; then
  echo "ℹ️ $TARGET_USER は既に docker グループのメンバーです。"
else
  echo "🔧 $TARGET_USER を docker グループに追加します..."
  sudo usermod -aG docker "$TARGET_USER"
  echo "✅ $TARGET_USER を docker グループに追加しました"
fi

echo "🎉 === Docker Engine セットアップ完了 ==="
