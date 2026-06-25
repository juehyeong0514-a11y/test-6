#!/usr/bin/env bash
set -euo pipefail

WEB_ROOT="${WEB_ROOT:-/var/www/html}"

if [ ! -f "$WEB_ROOT/index.html" ]; then
  echo "index.html was not found in $WEB_ROOT"
  exit 1
fi

if command -v systemctl >/dev/null 2>&1; then
  systemctl is-active --quiet bookapp || {
    echo "bookapp service is not active"
    systemctl status bookapp --no-pager || true
    exit 1
  }
fi

if command -v curl >/dev/null 2>&1; then
  curl -fsS http://localhost/ >/dev/null || {
    echo "HTTP validation failed for http://localhost/"
    exit 1
  }
  curl -fsS http://localhost/api/books >/dev/null || {
    echo "Backend validation failed for http://localhost/api/books"
    exit 1
  }
fi

echo "Deployment validation succeeded."
