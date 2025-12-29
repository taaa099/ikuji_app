#!/bin/bash
set -e

echo "===== entrypoint-sidekiq.sh START ====="

echo "Executing CMD: $@"
exec "$@"