<img src="docs/cover.png" alt="Patch Relay" width="220" align="right">

# 🛡️ BG3 Underslumber — Patch Relay

[English](README.en.md) · **Русский**

Приватный слой патчей поверх чужих модов Baldur's Gate 3. Обычно он переопределяет отдельные записи в статах и добавляет точечные обработчики Script Extender; собственные варианты предметов заводятся только как явно документированные продолжения исходных записей.

Страница мода: [BG3 Underslumber — Patch Relay на mod.io](https://mod.io/g/baldursgate3/m/bg3-underslumber-patch-relay).

Публикация GitHub Release на mod.io выполняется [отдельным workflow через официальный BG3 Toolkit](docs/modio-publishing.md); исходником всегда служит этот репозиторий целиком, включая `Mods/` и `Public/`.

В статах BG3 побеждает последняя загруженная запись, поэтому мод обязан стоять **ниже** всех патчируемых модов в порядке загрузки.

***

## 📋 Патчи

Таблица — оглавление: строка на патч, подробности в отдельном файле. Полное описание включает версию чужого мода на момент патча, переопределённые поля, исходное содержимое («Базис») и причину правки — по нему после апдейта чужого мода видно, жив патч или пора его переписывать.

| Патч | Мод | Что делает |
|:---|:---|:---|
| 🗡️ [`BLADESONG` — лестница КД](docs/patches/dnd55e-bladesong.md) | 📦 [DnD 5.5e All-in-One BEYOND](#-затронутые-моды) | 💡 Бонус Песни клинка продлён с потолка +7 до +10 к 30 Интеллекта; семь слагаемых свёрнуты в одну строку тултипа |
| ⚔️ [Оружие договора вне слота](docs/patches/dnd55e-pact-weapon.md) | 📦 [DnD 5.5e All-in-One BEYOND](#-затронутые-моды) | 💡 Привязка пакта переживает перенос оружия в инвентарь: Lua-обработчик возвращает снятые статусы `PACT_BLADE*` |
| 🎲 [Капсулы Пустоты: награда и расширенные пулы](docs/patches/ancient-mega-pack-void-capsule.md) | 📦 [Ancient Mega Pack](#-затронутые-моды) | 💡 Исправляет пустую награду и автоматически дополняет штатные пулы снаряжением активных модов по редкости, слоту и тематике |
| 🎩 [«Вечное эхо» очень редкой шляпы](docs/patches/ancient-mega-pack-eternal-echo.md) | 📦 [Ancient Mega Pack](#-затронутые-моды) | 💡 Исправляет фактический дополнительный урон с ×1 до заявленных ×1,5 модификатора Интеллекта |
| 🔨 [Оглушение редких булав](docs/patches/ancient-mega-pack-mace-stun.md) | 📦 [Ancient Mega Pack](#-затронутые-моды) | 💡 Приводит длительность оглушения редкой и очень редкой булав к заявленным 2 и 3 ходам |
| 💠 [Две версии «Кулона древнего усиления»](docs/patches/xfed-arcane-augmentation-pendant.md) | 📦 [Fade's Equipment Distribution AIO](#-затронутые-моды) | 💡 Исправляет русские описания очень редкой версии и добавляет отдельное легендарное завершение в мировую добычу xFED и легендарные капсулы |
| ⚙️ [Нереализованные свойства xFED](docs/patches/xfed-missing-item-mechanics.md) | 📦 [Fade's Equipment Distribution AIO](#-затронутые-моды) | 💡 Реализует заклинательную характеристику Starsong Blade, возврат дротика и исправляет испытание ауры спор |
| 📝 [Русская локализация xFED](docs/patches/xfed-russian-localization.md) | 📦 [Fade's Equipment Distribution AIO](#-затронутые-моды) | 💡 Добавляет 23 отсутствующие строки и исправляет 35 описаний, расходившихся с механикой предметов |
| 🏺 [Описания Ancient Mega Pack](docs/patches/ancient-mega-pack-russian-localization.md) | 📦 [Ancient Mega Pack](#-затронутые-моды) | 💡 Исправляет английские и русские описания распылятора, кулона и 40 вариантов оружия |

### 🗑️ Снятые

Апстрим починил вопрос сам — патч удаляется из мода, а его строка переезжает сюда. Пока таких нет.

***

## 🎮 Затронутые моды

| Мод | Что это | Ресурсы |
|:---|:---|:---|
| 🎲 [DnD 5.5e All-in-One BEYOND](https://mod.io/g/baldursgate3/m/bg3dnd) | 📖 Перевод BG3 на правила D&D 2024 (5.5e): классы, подклассы, черты, заклинания, предыстории и базовые правила | 🔗 [карточка](docs/patched-mods.md#dnd-55e-all-in-one-beyond) · 📂 [исходники](https://github.com/Yoonmoonsik/bg3dnd) · 🍴 [форк](https://github.com/Underslumber/bg3dnd) |
| 🏺 [Ancient Mega Pack](https://mod.io/g/baldursgate3/m/ancient-mega-pack-rel) | 🎁 Большой набор предметов, случайной добычи и капсул Пустоты | 🔗 [карточка](docs/patched-mods.md#ancient-mega-pack) · 📦 [страница и сборка](https://mod.io/g/baldursgate3/m/ancient-mega-pack-rel) · 📂 распакованная локальная копия |
| 💠 [Fade's Equipment Distribution AIO](https://mod.io/g/baldursgate3/m/fades-equipment-distribution-aio) | 🧰 Распределение по миру комплектов снаряжения для классов | 🔗 [карточка](docs/patched-mods.md#fades-equipment-distribution-aio) · 📦 [страница и сборка](https://mod.io/g/baldursgate3/m/fades-equipment-distribution-aio) · 📂 распакованная локальная копия |
