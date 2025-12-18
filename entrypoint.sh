#!/bin/bash
set -e

echo "===== entrypoint.sh START ====="

# PIDファイル削除
echo "Removing old PID file..."
rm -f tmp/pids/server.pid

# 本番では必須
if [ -z "$SECRET_KEY_BASE" ]; then
  echo "ERROR: SECRET_KEY_BASE is not set"
  exit 1
else
  echo "SECRET_KEY_BASE is set"
fi

# DB接続確認 + 必要なら作成 / migrate
echo "Running db:prepare..."
bundle exec rails db:prepare
echo "db:prepare finished"

# CMD を実行
echo "Executing CMD: $@"
exec "$@"