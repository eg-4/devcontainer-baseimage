#!/bin/bash

# ビルド引数バリデーションスクリプト

set -euo pipefail

# バリデーションエラーフラグ
HAS_ERROR=false

echo "🚀 === ビルド引数バリデーション開始 ==="

# EMAIL のバリデーション
if [ -z "$GIT_USER_EMAIL" ]; then
  echo "❌ エラー: GIT_USER_EMAIL引数が指定されていません"
  HAS_ERROR=true
elif ! echo "$GIT_USER_EMAIL" | grep -E "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$" > /dev/null; then
  echo "❌ エラー: 有効なメールアドレス形式ではありません: $GIT_USER_EMAIL"
  HAS_ERROR=true
fi

# NAME のバリデーション
if [ -z "$GIT_USER_NAME" ]; then
  echo "❌ エラー: GIT_USER_NAME引数が指定されていません"
  HAS_ERROR=true
elif [ -z "$(echo "$GIT_USER_NAME" | tr -d '[:space:]')" ]; then
  echo "❌ エラー: GIT_USER_NAME引数が空または空白文字のみです"
  HAS_ERROR=true
fi

# バリデーション結果の処理
if [ "$HAS_ERROR" = true ]; then
  cat << EOF

正しい使用例：
  1. .envファイルを作成:
     cp .env.example .env

  2. .envファイルを編集してメールアドレスと名前を設定:
     GIT_USER_EMAIL=your-email@example.com
     GIT_USER_NAME=Your Name

  3. Docker Composeでビルド:
     docker compose build

  または直接ビルド引数を指定:
     docker build --build-arg GIT_USER_EMAIL="your-email@example.com" --build-arg GIT_USER_NAME="Your Name" .
EOF
  exit 1
else
  echo "🎉 バリデーション完了: GIT_USER_EMAIL=$GIT_USER_EMAIL, GIT_USER_NAME=$GIT_USER_NAME"
fi
