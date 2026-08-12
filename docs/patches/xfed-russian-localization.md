# Русская локализация xFED

| | |
|---|---|
| Мод | [Fade's Equipment Distribution AIO](../patched-mods.md#fades-equipment-distribution-aio) |
| Версия на момент патча | 1.0.0.20 (`Version64` `36028797018963988`) |
| Файлы в Patch Relay | `Mods/…/Localization/Russian/FED_RU.xml`, `FF_Cleric_Equipment.xml`, `GG_Druid_Equipment.xml`, `OO_Paladin_Equipment.xml`, `PP_Warlock_Equipment.xml`, `SS_Bard_Equipment.xml`, `UU_Monk_Equipment.xml`, `WW_Wizard_Equipment.xml`; дополнение `CC_Sorcerer_Equipment.xml` |
| Файлы в чужом моде | `Mods/…/Localization/{English,Russian}/` с теми же именами; исключение рандомизатора: английский `FED_Loca.xml`, русский `FED_RU.xml` |
| Переопределённые строки | 23 отсутствовавшие русские строки и 4 ошибочных описания: `hff40…e20`, `h27ad…b022`, `hdb60…2a15`, `h154d…78da8` |
| Базис | В английской локализации 2003 UID, в русской 1980; все 23 отсутствующих UID пользовательские. Четыре существующих русских описания расходились со статами и параметрами механик |

Patch Relay добавляет только отсутствующие или исправленные русские строки под исходными `contentuid`. Английская локализация и stats xFED не меняются.

Для четырёх смысловых исправлений базис подтверждён статами xFED: кровожадность восстанавливает четверть нанесённого урона, а не 20 %; восстановление ОЗ равно полному кругу использованной ячейки; безоружные атаки получают и дополнительный урон, и бонус к броску атаки; лучистый взрыв учитывает испытание Выносливости, помеху злым существам, половинный базовый урон добрым и дополнительное уменьшение урона при успехе.

Термины сверены с `glossary/glossary.official.json`, затем с `glossary/glossary.normalized.json` и официальным корпусом проекта `bg3-dnd55e-russian-localization`. Сам перевод DnD 5.5e не изменяется.
