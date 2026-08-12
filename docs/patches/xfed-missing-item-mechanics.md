# Исправления механик предметов xFED

| | |
|---|---|
| Мод | [Fade's Equipment Distribution AIO](../patched-mods.md#fades-equipment-distribution-aio) |
| Версия на момент патча | 1.0.0.20 (`Version64` `36028797018963988`) |
| Файлы в Patch Relay | `SS_Passives.txt`, `GG_Spell_Shout.txt`, `GG_Passives.txt`, `PP_Armor.txt`; описания в классовых XML |
| Файлы в чужом моде | Одноимённые файлы в `Public/xFED_AIO_…/Stats/Generated/Data/` |
| Переопределённые записи | `SS_AstralConduit_Text`, `Shout_GG_Three_PoisonAura`, `GG_Three_Druid_ExtraWildShape_Passive`, две версии `PP_Warlock_Equipment_Tunic_of_the_Ascended_Warlock` |
| Базис | Отсутствующий `Boosts`, опечатка `Ability.Consititution`, ссылка на несуществующий статус и две ссылки на несуществующие пассивки |

Starsong Blade обещал использовать заклинательную характеристику вместо Ловкости, но `SS_AstralConduit_Text` не содержал `Boosts`. Патч добавляет только `WeaponAttackRollAbilityOverride(SpellCastingAbility)`. У ядовитой ауры исправлено только имя характеристики в испытании: `Consititution` → `Constitution`.

Дополнительный Дикий облик обращался к отсутствующему `GG_THREE_WILDSHAPE_DEPLETED_TECHNICAL`; ссылка заменена на существующий авторский статус `GG_THREE_EXTRA_WILDSHAPE_DEPLETED_TECHNICAL`. Из обеих версий туники удалены только две несуществующие passive-ссылки Цепи; работающие ауры `PP_AP_CHAIN_AURA*` и остальные свойства предмета наследуются без изменений.
