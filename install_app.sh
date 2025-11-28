#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/opt/hello-monitor/app"
SYSTEMD_DIR="/etc/systemd/system"

if [[ "$EUID" -ne 0 ]]; then
	echo "Run as root (sudo $0)" >&2
	exit 1
fi

echo "Installing Hello app to $APP_DIR"
mkdir -p "$APP_DIR"
cp -r app/* "$APP_DIR/"

echo "Installing hello-app.service"
cp systemd/hello-app.service "$SYSTEMD_DIR/hello-app.service"

echo "Reloading systemd"
systemctl daemon-reload
systemctl enable --now hello-app.service

echo "App installed!"
