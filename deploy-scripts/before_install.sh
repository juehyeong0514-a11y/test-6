#!/usr/bin/env bash
set -euo pipefail

WEB_ROOT="${WEB_ROOT:-/var/www/html}"

mkdir -p "$WEB_ROOT"
find "$WEB_ROOT" -mindepth 1 -maxdepth 1 -exec rm -rf {} +

echo "Prepared web root: $WEB_ROOT"
