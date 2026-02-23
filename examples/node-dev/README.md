# Node.js Development Environment

このサンプルは、共通のベースイメージからasdfを利用してNode.js開発環境を構築するデモです。TypeScript、React、Next.js、Tailwind CSSを使用したシンプルなWebアプリケーションのサンプルが含まれています。

## 🛠️ 技術スタック

- **Node.js** (asdf管理)
- **TypeScript** - 型安全なJavaScript
- **React** - UIライブラリ
- **Next.js** - Reactフレームワーク
- **Tailwind CSS** - ユーティリティファーストCSS

## 🚀 VS Code devcontainer での使用方法

1. VS Codeで `examples/node-dev` フォルダを開く
2. **Command Palette** (Ctrl+Shift+P) を開く
3. "Dev Containers: Reopen in Container" を選択
4. コンテナのビルドと初期化を待つ
5. 初回起動時、自動的にNext.jsプロジェクトが作成されます

## 📦 利用可能なコマンド

```bash
# 開発サーバーの起動
npm run dev

# プロダクションビルド
npm run build

# 型チェック
npm run type-check

# コードフォーマット
npm run format

# リント
npm run lint
```
