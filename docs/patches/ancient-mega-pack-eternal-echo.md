# «Вечное эхо» очень редкой шляпы

| | |
|---|---|
| Мод | [Ancient Mega Pack](../patched-mods.md#ancient-mega-pack) |
| Версия на момент патча | 22.74.1.2 (`Version64` `803048110702985218`) |
| Файл в Patch Relay | `Public/…/Stats/Generated/Data/Extra_Items.txt` |
| Файл в чужом моде | `Public/…/Stats/Generated/Data/Extra_Items.txt` |
| Запись | `AMP_Bladesinger_Helmet_3_Passive` |
| Переопределённое поле | `StatsFunctors` |
| Базис | `DealDamage((IntelligenceModifier*2)/2,Slashing,Magical,,0,,true,false)` |

У очень редкой `Шляпы вечного эха` описание обещает дополнительный рубящий урон, равный модификатору Интеллекта ×1,5 (`DescriptionParams = 1.5`), но исходная формула умножает модификатор на 2 и сразу делит на 2, то есть фактически даёт ×1.

Патч мягко переопределяет только `StatsFunctors` формулой `DealDamage((IntelligenceModifier*3)/2,Slashing,Magical,,0,,true,false)`. `DescriptionParams`, условия для типов оружия и врага, контекст `OnAttack`, магический тип урона и срабатывание даже при промахе наследуются из Ancient Mega Pack. Обычная, редкая и легендарная версии не меняются.
