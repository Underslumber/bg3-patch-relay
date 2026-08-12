# Описания предметов xFED

| | |
|---|---|
| Мод | [Fade's Equipment Distribution AIO](../patched-mods.md#fades-equipment-distribution-aio) |
| Версия на момент патча | 1.0.0.20 (`Version64` `36028797018963988`) |
| Файлы в Patch Relay | `Mods/…/Localization/Russian/FED_RU.xml` и классовые `*_Equipment.xml` |
| Файлы в чужом моде | `Mods/…/Localization/{English,Russian}/`; для рандомизатора английский `FED_Loca.xml`, русский `FED_RU.xml` |
| Переопределённые строки | 23 отсутствовавшие русские строки и 35 существовавших описаний |
| Базис | 2003 английских UID против 1980 русских; механика 35 описаний проверена по 864 записям с `Description`, RootTemplates и Story xFED |

Patch Relay добавляет 23 реально используемые строки и исправляет числа, условия, сроки, испытания и пропущенные эффекты в 35 русских описаниях. В частности, исправлены формулы восстановления ОЗ и ресурсов, пороги ОЗ и очков колдовства, длительности состояний, круг «Адского возмездия», условия «Последнего рубежа», «Исчезающего тумана» и другие расхождения.

Строки `CC_AugmentedDefense_Passive` и `CC_AugmentedRetaliation_Passive` описаны отдельно в патче кулона и в число 35 не входят. Термины сверены с `glossary.official.json`, `glossary.normalized.json` и корпусом проекта `bg3-dnd55e-russian-localization`; сам перевод DnD 5.5e не изменяется.
