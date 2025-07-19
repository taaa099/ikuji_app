#!/bin/bash
set -e

# Rails サーバのPIDファイルが残っていたら削除（再起動対策）
rm -f tmp/pids/server.pid

# MySQLが立ち上がるまで待機（DB名やPWはdocker-compose.ymlで渡される）
until mysqladmin ping -h db -p"$IKUJI_APP_DATABASE_PASSWORD" --silent; do
  echo "Waiting for MySQL..."
  sleep 2
done

# 本番環境では SECRET_KEY_BASE が必要なのでチェック
if [ -z "$SECRET_KEY_BASE" ]; then
  echo "WARNING: SECRET_KEY_BASE is not set"
fi

# 初回はDB起動を待つ
bundle exec rails db:prepare

# assets:precompile（事前に存在確認）
if [ ! -d "public/assets" ] || [ -z "$(ls -A public/assets)" ]; then
  echo "Precompiling assets..."
  bundle exec rails assets:precompile
else
  echo "Assets already precompiled, skipping..."
fi

# CMD ["rails", "server", "-b", "0.0.0.0"] を実行
exec "$@"