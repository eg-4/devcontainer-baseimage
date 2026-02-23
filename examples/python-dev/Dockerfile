# syntax=docker/dockerfile:1

FROM devcontainer-baseimage:latest

# Python固有の最小限のツールをインストール
RUN <<EOF
sudo apt-get update -qq
sudo apt-get install -qq -y \
  python3-pip \
  python3-venv \
  python3-dev

# クリーンアップ
sudo apt-get autoremove -y
sudo apt-get clean
rm -rf /var/lib/apt/lists/*

# pythonコマンドのシンボリックリンクを作成
sudo ln -sf /usr/bin/python3 /usr/bin/python
EOF

# エントリーポイントスクリプトをコピー
COPY ./dev-scripts/python-dev-entrypoint.sh /dev-scripts/python-dev-entrypoint.sh
RUN chmod +x /dev-scripts/python-dev-entrypoint.sh

ENTRYPOINT ["/dev-scripts/python-dev-entrypoint.sh"]
