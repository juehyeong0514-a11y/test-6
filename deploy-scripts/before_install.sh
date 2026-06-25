#!/usr/bin/env bash
set -euo pipefail

WEB_ROOT="${WEB_ROOT:-/var/www/html}"
APP_DIR="${APP_DIR:-/opt/bookapp}"

if command -v systemctl >/dev/null 2>&1 && systemctl list-unit-files | grep -q '^bookapp.service'; then
  systemctl stop bookapp || true
fi

# 💡 [수정] lsof 명령어 자체의 실패(포트가 비어있음)를 허용하도록 처리
if command -v lsof >/dev/null 2>&1; then
  (lsof -ti:8080 | xargs -r kill -9) || true
elif command -v fuser >/dev/null 2>&1; then
  fuser -k 8080/tcp || true
fi

mkdir -p "$APP_DIR"
mkdir -p "$WEB_ROOT"

# 💡 [수정] find 결과가 없어도 스크립트가 죽지 않도록 뒤에 || true 추가
find "$WEB_ROOT" -mindepth 1 -maxdepth 1 -exec rm -rf {} + || true
find "$APP_DIR" -mindepth 1 -maxdepth 1 -name '*.jar' -exec rm -f {} + || true

echo "Prepared web root: $WEB_ROOT"
echo "Prepared app dir: $APP_DIR"