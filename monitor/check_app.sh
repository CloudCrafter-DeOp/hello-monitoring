#!/usr/bin/env bash
# Скрипт мониторинга веб-приложения
# Читаем конфиг, проверяем доступность веб-приложения, 
# логируем, перезапускаем приложение в случае недоступности
# делаем самообновление скрипта мониторинга

set -euo pipefail

# путь к осн. конфиг файлу
CONFIG_FILE="/etc/hello-monitor/config.env"

# если системного конфига нет, то запускаем локальный
if [[ ! -f "$CONFIG_FILE"  ]]; then
	SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCCE[0]}")" && pwd)"
	CONFIG_FILE="${SCRIPT_DIR}/config.env"
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
	echo "!!!Config File not found!!!" >&2
	exit 1
fi

# переменные из конфига
. "$CONFIG_FILE"

timestamp() {
  date +"%Y-%m-%d %H:%M:%S"
}

log() {
  local level="$1"
  local msg="$2"
  echo "$(timestamp) [$level] $msg" >> "$LOG_FILE"
}

check_app() {
  local code
  code="$(curl -s -o /dev/null -w "%{http_code}" "$APP_URL" || echo "000")"

  if [[ "$code" == "$EXPECTED_HTTP_CODE" ]]; then
	log "INFO" "App is UP (code=$code)"
	return 0
  else
	log "ERROR" "App is DOWN (code=$code) restarting..."
	if eval "$RESTART_CMD"; then
		log "INFO" "Restart cmd succeeded"
		return 1
	else
		log "ERROR" "Restart cmd FAILED"
		return 2
	fi
  fi
}

check_for_update() {
  if [[ -z "${UPDATE_BASE_URL:-}" || -z "${VERSION_FILE:-}" ]]; then
	return 0
  fi

  local local_v="0"
  local remote_v

  if [[ -f "$VERSION_FILE" ]]; then
	local_v="$(cat "$VERSION_FILE" 2>/dev/null || echo "0")"
  fi

  remote_v="$(curl -fsS "$UPDATE_BASE_URL/monitor/version.txt" 2>/dev/null || echo "$local_v")"

  if [[ "$remote_v" == "$local_v" ]]; then
	return 0
  fi

  log "INFO" "Found New Version. Updating..."

  tmp="$(mktemp)"
  if curl -fsS "$UPDATE_BASE_URL/monitor/check_app.sh" -o "$tmp"; then
	chmod +x "$tmp"
	mv "$tmp" "$0"
	echo "$remote_v" > "$VERSION_FILE"
	log "INFO" "Monotor updated to version $remote_v"
  else
	log "ERROR" "Failed update monitor"
	rm -f "$tmp"
  fi
}

check_app

check_for_update
