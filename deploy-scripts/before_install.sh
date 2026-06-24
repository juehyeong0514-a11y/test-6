#!/usr/bin/env bash
set -euo pipefail

WEB_ROOT="${WEB_ROOT:-/var/www/html}"
APP_DIR="${APP_DIR:-/opt/bookapp}"

if command -v systemctl >/dev/null 2>&1 && systemctl list-unit-files | grep -q '^bookapp.service'; then
  systemctl stop bookapp || true
fi

if command -v lsof >/dev/null 2>&1; then
  lsof -ti:8080 | xargs -r kill -9
elif command -v fuser >/dev/null 2>&1; then
  fuser -k 8080/tcp || true
fi

mkdir -p "$APP_DIR"
mkdir -p "$WEB_ROOT"
find "$WEB_ROOT" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
find "$APP_DIR" -mindepth 1 -maxdepth 1 -name '*.jar' -exec rm -f {} +

echo "Prepared web root: $WEB_ROOT"
echo "Prepared app dir: $APP_DIR"
