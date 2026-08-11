# Легендарный «Кулон древнего усиления»

| | |
|---|---|
| Мод | [Fade's Equipment Distribution AIO](../patched-mods.md#fades-equipment-distribution-aio) |
| Версия на момент патча | 1.0.0.20 (`Version64` `36028797018963988`) |
| Файлы в Patch Relay | `Public/…/Stats/Generated/Data/CC_Armor.txt`, `CC_Passives.txt`; `Public/…/RootTemplates/_merged.lsx`; `Public/…/Stats/Generated/TreasureTable.txt`; `Mods/…/Localization/{English,Russian}/CC_Sorcerer_Equipment.xml`; `Mods/…/ScriptExtender/Lua/BootstrapServer.lua` |
| Файлы в чужих модах | xFED: `Public/…/Stats/Generated/Data/CC_Armor.txt`, `CC_Passives.txt`, `Public/…/RootTemplates/_merged.lsx`, `Mods/…/Story/RawFiles/Goals/FED_Randomizer.txt`; Ancient Mega Pack: `Public/…/Stats/Generated/TreasureTable.txt` |
| Новые записи | `PR_CC_Sorcerer_Equipment_Pendant_of_Arcane_Augmentation_Legendary`, `PR_CC_AugmentedDefense_Legendary_Passive`, `PR_CC_AugmentedRetaliation_Legendary_Passive`; RootTemplate `8b08e722-c75b-43d2-a83c-a04e6543cf7e` |
| Переопределённые строки оригинала | Только русские описания `CC_AugmentedDefense_Passive` (`…3b012`) и `CC_AugmentedRetaliation_Passive` (`…3b016`); stats и английские строки оригинала не меняются |
| Базис кулона | `CC_Sorcerer_Equipment_Pendant_of_Arcane_Augmentation`: `Rarity = VeryRare`, `ComboCategory = d3`, RootTemplate `28fd8a38-fd95-4ba2-bad6-a5dc0e25e2e4` |
| Базис защиты | При Харизме 14–17: `AC(1)`; 18–21: `AC(2)`; от 22: `AC(3)`. Условие `not WearingArmor(context.Source)` |
| Базис возмездия | `DescriptionParams = DealDamage(CharismaModifier/2,Force)`; `StatsFunctors = DealDamage(SWAP,CharismaModifier/2,Force,Magical)` |

Patch Relay не переопределяет stats исходного очень редкого кулона или его пассивок. Для него исправлены только две русские строки: защита теперь прямо указывает половину модификатора Харизмы, округление вниз и потолок +3, а возмездие срабатывает именно после попадания ближней атакой. Английское описание защиты уже соответствовало формуле xFED и не меняется.

Легендарный предмет заведён отдельно: он наследует внешний вид, название и художественное описание оригинала, но имеет собственные stats, RootTemplate и пассивки. Поэтому в игре одновременно существуют очень редкая и легендарная версии.

«Древняя защита» добавляет полный модификатор Харизмы к КБ с потолком +4: +1 при Харизме 12–13, +2 при 14–15, +3 при 16–17 и +4 от 18. В то же условие отсутствия брони встроено завершение рунического силового каркаса: `Attribute(Grounded)` запрещает противнику принудительно перемещать владельца, а иммунитеты `SG_Prone` и конкретных вариантов `PRONE*` не дают сбить его с ног, включая лёд и разряд Реверберации.

«Древнее возмездие» раз за ход возвращает попавшему в ближнем бою противнику силовой урон, равный полному модификатору Харизмы вместо половины. Условие ближней атаки, защита от перенаправленного урона, магический тип и ограничение `OncePerTurn` наследуются из xFED.

При `SessionLoaded` обработчик Script Extender идемпотентно добавляет stats предмета в `DB_FED_ItemRarity` с редкостью `Legendary`, а его RootTemplate — в `DB_FED_Legendary_Pool`. Так отдельная версия участвует в штатной замене легендарной мировой добычи xFED. Через объединяемые (`CanMerge 1`) таблицы `REL_Legendary_Amulets` и `REL_All_Legendary` тот же предмет добавлен соответственно в амулетные и общие легендарные капсулы Ancient Mega Pack.

Английские и русские строки легендарных пассивок созданы под новыми handle и не пересекаются с оригиналом. Механика легендарных пассивок проверена в игре на прежнем переопределении; отдельный RootTemplate и три новых маршрута выпадения требуют проверки фактическим получением нового экземпляра.
