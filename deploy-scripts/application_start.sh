#!/usr/bin/env bash
set -euo pipefail

reload_service() {
  local service_name="$1"

  if command -v systemctl >/dev/null 2>&1; then
    systemctl reload "$service_name" || systemctl restart "$service_name"
  else
    service "$service_name" reload || service "$service_name" restart
  fi
}

if command -v nginx >/dev/null 2>&1; then
  nginx -t
  reload_service nginx
  echo "Nginx reloaded."
elif command -v apache2 >/dev/null 2>&1; then
  reload_service apache2
  echo "Apache reloaded."
elif command -v httpd >/dev/null 2>&1; then
  reload_service httpd
  echo "HTTPD reloaded."
else
  echo "No supported web server command found. Static files were deployed only."
fi
