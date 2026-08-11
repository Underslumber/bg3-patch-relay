# Патчируемые моды

Идентичность каждого чужого мода, который патчит Patch Relay, и откуда брать оригинал записи при сверке. Сами патчи — отдельными файлами в [`docs/patches/`](patches/), сводная таблица — в [README](../README.md#патчи).

Новый мод в этом списке ходит парой с записью в `Dependencies` внутри `Mods/…/meta.lsx` (Folder, Name, UUID, PublishHandle, Version64).

## DnD 5.5e All-in-One BEYOND

| | |
|---|---|
| UUID | `897914ef-5c96-053c-44af-0be823f895fe` |
| Folder | `DnD2024_897914ef-5c96-053c-44af-0be823f895fe` |
| PublishHandle | `4419649` |
| Страница мода | https://mod.io/g/baldursgate3/m/bg3dnd |
| Исходники | https://github.com/Yoonmoonsik/bg3dnd (апстрим) |
| Форк | https://github.com/Underslumber/bg3dnd |
| Где искать оригинал записи | `Public/DnD2024_897914ef-5c96-053c-44af-0be823f895fe/Stats/Generated/Data/` — путь зеркалит наш |

## Ancient Mega Pack

| | |
|---|---|
| UUID | `c6c0d2bd-6198-de9e-30ad-e8cda1793025` |
| Folder | `REL_Full_Ancient_c6c0d2bd-6198-de9e-30ad-e8cda1793025` |
| PublishHandle | `4474487` |
| Страница мода | https://mod.io/g/baldursgate3/m/ancient-mega-pack-rel |
| Исходники | Публичный репозиторий не указан; базис берётся из распакованного установленного `.pak` |
| Локальная копия | `D:/Projects/BG3_Mods/work/ancient_current/` |
| Где искать оригинал записи | Капсулы: `Mods/REL_Full_Ancient_c6c0d2bd-6198-de9e-30ad-e8cda1793025/Story/RawFiles/Goals/ZZ_AMP_VoidCapsule_*.txt`; предметы: `Public/REL_Full_Ancient_c6c0d2bd-6198-de9e-30ad-e8cda1793025/Stats/Generated/Data/` — путь зеркалит наш |

## Fade's Equipment Distribution AIO

| | |
|---|---|
| UUID | `af330e86-7335-b20c-ce70-6df8539d4597` |
| Folder | `xFED_AIO_af330e86-7335-b20c-ce70-6df8539d4597` |
| PublishHandle | `4918115` |
| Страница мода | https://mod.io/g/baldursgate3/m/fades-equipment-distribution-aio |
| Исходники | Публичный репозиторий не указан; базис берётся из распакованного установленного `.pak` |
| Локальная копия | `D:/Projects/BG3_Mods/work/xfed_live_1_0_0_20/` |
| Где искать оригинал записи | Статы: `Public/xFED_AIO_af330e86-7335-b20c-ce70-6df8539d4597/Stats/Generated/Data/CC_Armor.txt` и `CC_Passives.txt`; шаблон: `Public/…/RootTemplates/_merged.lsx`; тексты: `Mods/…/Localization/{English,Russian}/CC_Sorcerer_Equipment.xml`; мировая легендарная добыча: `Mods/…/Story/RawFiles/Goals/FED_Randomizer.txt` |
