# Python開発環境

このディレクトリには、`devcontainer-baseimage`ベースに最小限のPython開発ツールを追加したシンプルな環境が含まれています。

## 含まれているもの

- `devcontainer-baseimage`の共通開発ツール（git、curl、エディタ等）
- Python 3.x + pip
- Pythonパッケージ（requests、pytest）
- サンプルアプリケーション
- サンプルテストケース

## 使用方法

### 環境の起動

```bash
docker compose up --build -d
```

### コンテナに入る

```bash
docker compose exec python-dev bash
```

### サンプルアプリの実行

```bash
docker compose exec python-dev python sample_app.py
```

### テストの実行

```bash
docker compose exec python-dev pytest test_sample_app.py
```

### カスタムコマンドの実行

```bash
docker compose exec python-dev python -c "print('Hello from Docker!')"
```

## カスタマイズ

- `requirements.txt` に必要なパッケージを追加
- `sample_app.py` を参考に独自のアプリケーションを作成
- 必要に応じて `Dockerfile` にPython固有のパッケージを追加
- `devcontainer-baseimage`の共通ツール（git、curl等）も利用可能
