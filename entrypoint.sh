#! /bin/bash
set -e

# 初回はDB起動を待つ
bundle exec rails db:prepare

# コンテナを立ち上げる
exec "$@"