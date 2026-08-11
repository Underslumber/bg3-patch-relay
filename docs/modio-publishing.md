# Публикация на mod.io

Workflow `.github/workflows/publish-modio.yml` публикует Patch Relay через официальный Baldur's Gate 3 Toolkit на выделенном Windows runner с меткой `patch-relay-toolkit`.

Он запускается автоматически для опубликованного GitHub Release или вручную с `ref` и `version_tag`. Ручной запуск по умолчанию работает в безопасном режиме `validate_only`: проверяет runner, Toolkit и авторизованную вкладку управления Patch Relay, но не загружает новый файл.

Источником всегда служит checkout самого `bg3-patch-relay`. Скрипт `stage-toolkit-project.ps1` подключает его `Mods`, `Public`, `Editor/Mods` и `Projects` к игре отдельными junction-ссылками. Workflow не читает и не запускает файлы других модов.

После загрузки через Toolkit скрипт `finalize-modio-browser.mjs` работает только со страницей `bg3-underslumber-patch-relay`. Он запоминает старые File ID, находит новый файл требуемой версии, ждёт успешного сканирования, включает Windows и публикует файл. Успех принимается только после подтверждения активной Windows-версии в менеджере файлов и появления нового File ID на публичной странице.

## Требования runner

- Windows x64 runner `BG3-MODIO-PATCH-RELAY` с меткой `patch-relay-toolkit` и интерактивной сессией пользователя `modiorunner`;
- установленный и предварительно авторизованный BG3 Toolkit;
- Yandex Browser с CDP на `127.0.0.1:9222` и авторизованной сессией mod.io;
- VM-скрипт `C:\ProgramData\BG3Modio\Publish-Modio-Toolkit.ps1`;
- Node.js из каталога runner, запускаемый с `--experimental-websocket`.

Секрет `MODIO_ACCESS_TOKEN` не требуется: Toolkit и mod.io используют сохранённые авторизованные сессии выделенной VM. Диагностика Toolkit, проверка браузера и результат финализации сохраняются как artifact каждого запуска.
