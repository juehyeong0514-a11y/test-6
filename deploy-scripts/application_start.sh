#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-/opt/bookapp}"
WEB_ROOT="${WEB_ROOT:-/var/www/html}"
APP_JAR="$APP_DIR/bookapp.jar"
JAVA_BIN=""

install_package() {
  local package_name="$1"

  if command -v dnf >/dev/null 2>&1; then
    dnf install -y "$package_name"
  elif command -v yum >/dev/null 2>&1; then
    yum install -y "$package_name"
  elif command -v apt-get >/dev/null 2>&1; then
    apt-get update
    apt-get install -y "$package_name"
  else
    echo "No supported package manager found to install $package_name"
    return 1
  fi
}

ensure_java() {
  if command -v java >/dev/null 2>&1; then
    JAVA_BIN="$(command -v java)"
    return
  fi

  install_package java-17-amazon-corretto-headless || install_package java-17-openjdk-headless || install_package openjdk-17-jre-headless
  JAVA_BIN="$(command -v java)"
}

reload_service() {
  local service_name="$1"

  if command -v systemctl >/dev/null 2>&1; then
    systemctl reload "$service_name" || systemctl restart "$service_name"
  else
    service "$service_name" reload || service "$service_name" restart
  fi
}

ensure_java
if ! command -v curl >/dev/null 2>&1; then
  install_package curl
fi
mkdir -p "$APP_DIR/data" "$APP_DIR/uploads/covers"

JAR_SOURCE="$(find "$APP_DIR" -maxdepth 1 -type f -name '*.jar' ! -name '*plain*.jar' | head -n 1)"
if [ -z "$JAR_SOURCE" ]; then
  echo "Backend jar was not found in $APP_DIR"
  exit 1
fi

if [ "$JAR_SOURCE" != "$APP_JAR" ]; then
  cp "$JAR_SOURCE" "$APP_JAR"
fi

cat >/etc/systemd/system/bookapp.service <<SERVICE
[Unit]
Description=Book App Spring Boot Backend
After=network.target

[Service]
Type=simple
WorkingDirectory=$APP_DIR
ExecStart=$JAVA_BIN -jar $APP_JAR
Restart=always
RestartSec=10
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable bookapp
systemctl restart bookapp

for i in $(seq 1 30); do
  if command -v curl >/dev/null 2>&1 && curl -fsS http://127.0.0.1:8080/books >/dev/null; then
    break
  fi

  if [ "$i" -eq 30 ]; then
    echo "Backend did not become ready on port 8080"
    systemctl status bookapp --no-pager || true
    journalctl -u bookapp -n 80 --no-pager || true
    exit 1
  fi

  sleep 2
done

if ! command -v nginx >/dev/null 2>&1; then
  install_package nginx
fi

cat >/etc/nginx/conf.d/bookapp.conf <<NGINX
server {
    listen 80;
    server_name _;

    root $WEB_ROOT;
    index index.html;

    location /api/ {
        proxy_pass http://127.0.0.1:8080/;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /uploads/ {
        alias $APP_DIR/uploads/;
        try_files \$uri =404;
    }

    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
NGINX

nginx -t
systemctl enable nginx
reload_service nginx

echo "Backend service and nginx proxy started."
