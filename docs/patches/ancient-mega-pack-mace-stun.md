# Оглушение редких булав Arcanizer

| | |
|---|---|
| Мод | [Ancient Mega Pack](../patched-mods.md#ancient-mega-pack) |
| Версия на момент патча | 22.74.1.2 (`Version64` `803048110702985218`) |
| Файл в Patch Relay | `Public/…/Stats/Generated/Data/Arcanizer_Main.txt` |
| Файл в чужом моде | `Public/…/Stats/Generated/Data/Arcanizer_Main.txt` |
| Переопределённые записи | Только `SpellSuccess` у `Target_Mace_r` и `Target_Mace_e` |
| Базис | `TooltipStatusApply` обещает `STUNNED` на 2/3 хода, но оба `SpellSuccess` накладывают его на 1 ход |

Лестница булав повышает КС и заявленную длительность с редкостью, но редкая и очень редкая версии фактически оглушали лишь на один ход. Патч меняет длительность в `SpellSuccess` на заявленные 2 и 3 хода, не затрагивая урон, КС или перезарядку.
