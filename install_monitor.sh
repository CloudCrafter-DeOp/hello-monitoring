#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/opt/hello-monitor"
MONITOR_DIR="$BASE_DIR/monitor"
CONFIG_DIR="/etc/hello-monitor"
SYSTEMD_DIR="/etc/systemd/system"
LOG_FILE="/var/log/hello-monitor.log"

# Проверка запуска от root-а
if [[ "$EUID" -ne 0 ]]; then
	echo "Run as root (sudo $0)" >&2
	exit 1
fi

# установка мониторинга в MONITOR_DIR, создание и перемещение файлов
echo "Installing monitor script $MONITOR_DIR"
mkdir -p "$MONITOR_DIR"
cp -r monitor/* "$MONITOR_DIR/"

# Установка конфига для мониторинга
echo "Installing config $CONFIG_DIR"
mkdir -p "$CONFIG_DIR"

if [[ ! -f "$CONFIG_DIR/config.env" ]]; then
	cp monitor/config.env "$CONFIG_DIR/config.env"
	echo "Created $CONFIG_DIR/config.env"
fi

# Перенос версии приложения в конфиг-директорию
if [[ ! -f "$CONFIG_DIR/version.txt" ]]; then
	cp monitor/version.txt "$CONFIG_DIR/version.txt"
fi


# Создание лог-файла
echo "Created log file $LOG_FILE"
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"

# установка .service & .timer в системную директорию
echo "Installing systemd for monitor"
cp systemd/hello-monitor.service "$SYSTEMD_DIR/hello-monitor.service"
cp systemd/hello-monitor.timer "$SYSTEMD_DIR/hello-monitor.timer"

# перезапуск systemd и включение нашего мониторинга
echo "Reloadig systemd..."
systemctl daemon-reload
echo "Enable and starting monitor"
systemctl enable --now hello-monitor.timer

echo "Monitor installing"
