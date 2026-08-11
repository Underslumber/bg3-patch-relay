# Публикация на mod.io

Workflow `.github/workflows/publish-modio.yml` публикует Patch Relay через официальный Baldur's Gate 3 Toolkit на Windows runner с меткой `bg3-toolkit`.

Он запускается автоматически для опубликованного GitHub Release или вручную с `ref` и `version_tag`. В отличие от снятой временной интеграции в репозитории локализации, источником служит сам `bg3-patch-relay`: скрипт `link-bg3-dev-folders.ps1` подключает к Toolkit все существующие ветки проекта — `Mods`, `Public`, `Editor/Mods` и `Projects`.

После загрузки Toolkit workflow ожидает окончания проверки mod.io, включает платформу Windows и делает новый файл активным через официальный API. Успех принимается только при подтверждённых состояниях проверки, активности файла и платформы.

## Требования runner

- Windows x64 runner с меткой `bg3-toolkit` и интерактивной сессией;
- установленный и предварительно авторизованный BG3 Toolkit;
- переменная `BG3TOOL_PATH`, если Toolkit находится не по стандартному пути;
- секрет `MODIO_ACCESS_TOKEN`, доступный репозиторию `bg3-patch-relay`;
- необязательная переменная `MODIO_API_BASE`.

Диагностика Toolkit и результат финализации сохраняются как artifact каждого запуска.
