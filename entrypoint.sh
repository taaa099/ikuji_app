#!/bin/bash
set -e

# PIDファイル削除
rm -f tmp/pids/server.pid

# 本番では必須
if [ -z "$SECRET_KEY_BASE" ]; then
  echo "ERROR: SECRET_KEY_BASE is not set"
  exit 1
fi

# DB接続確認 + 必要なら作成 / migrate
bundle exec rails db:prepare

# CMD を実行
exec "$@"