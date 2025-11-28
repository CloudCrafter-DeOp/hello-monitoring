# Hello monitoring

Система мониторинга веб-приложения с автоматическим перезапуском и автоматическим обновлением

## Состав

- `app/app.py` HTTP-сервер на Python, который отвечает `Hello World!`
- `monitor/check_app.sh` — скрипт мониторинга, который:
  - проверяет доступность `APP_URL`
  - пишет логи в `LOG_FILE`
  - выполняет `RESTART_CMD`, если приложение недоступно
  - выполняет автоматическое обновление, подтягивая версию из GitHub
- `monitor/config.env` пример конфигурации (URL, команда перезапуска, путь до логов)
- `monitor/version.txt` версия мониторинга
- `systemd/hello-app.service` unit для запуска веб-приложения
- `systemd/hello-monitor.service` unit одноразового запуска мониторинга
- `systemd/hello-monitor.timer` таймер, запускающий мониторинг каждые N секунд
- `install-app.sh` установка приложения
- `install-monitor.sh` установка мониторинга

## Установка

```bash
git clone https://github.com/CloudCrafter-DeOp/hello-monitoring.git
cd hello-monitoring

# установка (нужен root)

sudo ./install-app.sh
sudo ./install-monitor.sh
```

## Посмотреть логи

`tail -f /var/log/hello-monitor.log`
