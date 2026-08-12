# Нереализованные свойства предметов xFED

| | |
|---|---|
| Мод | [Fade's Equipment Distribution AIO](../patched-mods.md#fades-equipment-distribution-aio) |
| Версия на момент патча | 1.0.0.20 (`Version64` `36028797018963988`) |
| Файлы в Patch Relay | `SS_Passives.txt`, `RR_Weapon.txt`, `GG_Spell_Shout.txt`; русские описания в классовых XML |
| Файлы в чужом моде | `SS_Passives.txt`, `RR_Weapon.txt`, `RR_Status_BOOSTS.txt`, `GG_Spell_Shout.txt` |
| Переопределённые записи | `SS_AstralConduit_Text`, `RR_Barbarian_Equipment_Javelin_of_Returning_Fury`, `Shout_GG_Three_PoisonAura` |
| Базис | Пустой текстовый passive Starsong Blade; неподключённый `RR_THROWING_RETURN_TO_OWNER`; опечатка `Ability.Consititution` |

Starsong Blade обещал использовать заклинательную характеристику вместо Ловкости, но `SS_AstralConduit_Text` не содержал `Boosts`. Патч добавляет только `WeaponAttackRollAbilityOverride(SpellCastingAbility)`.

Для Javelin of Returning Fury в xFED уже существует статус `RR_THROWING_RETURN_TO_OWNER` с `ItemReturnToOwner()`, но оружие его не получало. Патч подключает готовый статус через `StatusOnEquip`. У ядовитой ауры исправлено только имя характеристики в испытании: `Consititution` → `Constitution`.
