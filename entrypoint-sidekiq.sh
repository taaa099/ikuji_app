#!/bin/bash
set -e

echo "===== entrypoint-sidekiq.sh START ====="

# 本番では必須
if [ -z "$SECRET_KEY_BASE" ]; then
  echo "ERROR: SECRET_KEY_BASE is not set"
  exit 1
else
  echo "SECRET_KEY_BASE is set"
fi

# CMD を実行
echo "Executing CMD: $@"
exec "$@"