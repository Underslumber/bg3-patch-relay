local MODULE_UUID = "146ee64d-4202-44ea-bd9a-87fbcc4aa36e"
local ANCIENT_UUID = "c6c0d2bd-6198-de9e-30ad-e8cda1793025"
local REPORT_PATH = "PatchRelay/capsule-pool-expansion-audit.log"
local ENABLE_POOL_MUTATION = true
local MAX_REFERENCE_DEPTH = 3
local MAX_REFERENCE_STATS = 96
local BASE_ITEM_STATS = Ext.Require("CapsulePoolBaseItems.lua")

local ITEM_STAT_TYPES = { "Armor", "Weapon" }

local SOURCE_MOD_EXCLUSIONS = {
    [MODULE_UUID] = true,
    [ANCIENT_UUID] = true
}

local RARITY_TO_POOL = {
    uncommon = "Uncommon",
    rare = "Rare",
    veryrare = "Epic",
    epic = "Epic",
    legendary = "Legendary"
}

local MECHANIC_FIELDS = {
    "DefaultBoosts",
    "Boosts",
    "Damage",
    "Damage Type",
    "VersatileDamage",
    "PassivesOnEquip",
    "StatusInInventory",
    "StatusOnEquip",
    "Spells",
    "UseConditions",
    "DescriptionParams",
    "TooltipDamageList",
    "WeaponFunctors",
    "ExtraProperties",
    "SpellProperties",
    "SpellSuccess",
    "SpellFail",
    "OnApplyFunctors",
    "OnRemoveFunctors",
    "OnTickFunctors",
    "TickFunctors",
    "Properties",
    "Conditions",
    "StatsFunctorContext",
    "UseCosts"
}

local THEME_RULES = {
    Arcane = {
        { "spellsavedc", "SpellSaveDC" },
        { "spellattack", "SpellAttack" },
        { "spellslot", "spell slot" },
        { "arcane", "Arcane" },
        { "wizard", "Wizard" },
        { "sorcer", "Sorcerer" },
        { "warlock", "Warlock" },
        { "metamagic", "Metamagic" },
        { "eldritch", "Eldritch" },
        { "intelligence", "Intelligence" },
        { "arcana", "Arcana" }
    },
    War = {
        { "meleeweaponattack", "melee weapon attack" },
        { "rangedweaponattack", "ranged weapon attack" },
        { "weaponattack", "weapon attack" },
        { "weapon damage", "weapon damage" },
        { "weaponDamage", "weapon damage" },
        { "fighter", "Fighter" },
        { "barbar", "Barbarian" },
        { "rage", "Rage" },
        { "superiority", "Superiority Die" },
        { "sneakattack", "Sneak Attack" },
        { "paladin", "Paladin" },
        { "smite", "Smite" },
        { "strength", "Strength" },
        { "athletics", "Athletics" },
        { "criticalattackthreshold", "critical threshold" }
    },
    Psionic = {
        { "psychic", "Psychic" },
        { "psionic", "Psionic" },
        { "illithid", "Illithid" },
        { "mindflayer", "Mind Flayer" },
        { "mind_", "mind mechanic" },
        { "thought", "thought mechanic" },
        { "intelligence", "Intelligence" },
        { "wisdom", "Wisdom" }
    },
    Nature = {
        { "druid", "Druid" },
        { "ranger", "Ranger" },
        { "wildshape", "Wild Shape" },
        { "wild shape", "Wild Shape" },
        { "nature", "Nature" },
        { "survival", "Survival" },
        { "plant", "plant mechanic" },
        { "animal", "animal mechanic" },
        { "beast", "beast mechanic" },
        { "wisdom", "Wisdom" }
    },
    Primal = {
        { "primal", "Primal" },
        { "wildmagic", "Wild Magic" },
        { "wild magic", "Wild Magic" },
        { "wildsurge", "Wild Surge" },
        { "wild surge", "Wild Surge" },
        { "metamagic", "Metamagic" },
        { "bard", "Bard" },
        { "sorcer", "Sorcerer" },
        { "constitution", "Constitution" },
        { "charisma", "Charisma" }
    },
    Celestial = {
        { "radiant", "Radiant" },
        { "healing", "healing" },
        { "heal(", "healing" },
        { "temporaryhp", "temporary HP" },
        { "bless", "Bless" },
        { "cleric", "Cleric" },
        { "paladin", "Paladin" },
        { "channeldivinity", "Channel Divinity" },
        { "divine", "Divine" },
        { "wisdom", "Wisdom" },
        { "charisma", "Charisma" }
    },
    Shadowfell = {
        { "necrotic", "Necrotic" },
        { "darkness", "Darkness" },
        { "shadow", "Shadow" },
        { "fear", "Fear" },
        { "fright", "Frightened" },
        { "undead", "Undead" },
        { "necrom", "Necromancy" },
        { "warlock", "Warlock" }
    },
    Swamp = {
        { "acid", "Acid" },
        { "poison", "Poison" },
        { "disease", "Disease" },
        { "spider", "Spider" },
        { "web", "Web" },
        { "mushroom", "Mushroom" },
        { "swamp", "Swamp" }
    },
    Aquatic = {
        { "cold", "Cold" },
        { "water", "Water" },
        { "wet", "Wet" },
        { "aquatic", "Aquatic" },
        { "lightning", "Lightning" },
        { "thunder", "Thunder" }
    },
    Destructive = {
        { "fire", "Fire" },
        { "lightning", "Lightning" },
        { "thunder", "Thunder" },
        { "force", "Force" },
        { "acid", "Acid" },
        { "cold", "Cold" },
        { "necrotic", "Necrotic" },
        { "dealdamage", "DealDamage" },
        { "weapondamage", "weapon damage" },
        { "criticalhit", "critical hit" },
        { "damagebonus", "damage bonus" }
    }
}

local auditCompleted = false

local function lower(value)
    return string.lower(tostring(value or ""))
end

local function sortedKeys(values)
    local result = {}
    for key in pairs(values or {}) do
        table.insert(result, key)
    end
    table.sort(result)
    return result
end

local function readStatValue(stat, field)
    local succeeded, value = pcall(function ()
        return stat[field]
    end)
    if not succeeded or value == nil then
        return ""
    end
    return tostring(value)
end

local function moduleInfo(modUuid)
    local succeeded, module = pcall(Ext.Mod.GetMod, modUuid)
    if not succeeded or module == nil or module.Info == nil then
        return tostring(modUuid), "", ""
    end
    return tostring(module.Info.Name or modUuid),
        tostring(module.Info.Author or ""),
        tostring(module.Info.Directory or "")
end

local function isOfficialModule(modUuid)
    local name, author, directory = moduleInfo(modUuid)
    local identity = lower(name .. " " .. author .. " " .. directory)
    return identity:find("larian", 1, true) ~= nil
        or identity:find("gustav", 1, true) ~= nil
        or identity:find("honourx", 1, true) ~= nil
end

local function readObjectValue(object, field)
    local succeeded, value = pcall(function ()
        return object[field]
    end)
    if not succeeded then
        return nil
    end
    return value
end

local function moduleUuid(module)
    local info = readObjectValue(module, "Info")
    if info == nil then
        return nil
    end

    local uuid = readObjectValue(info, "ModuleUUID")
        or readObjectValue(info, "UUID")
    if uuid == nil or tostring(uuid) == "" then
        return nil
    end
    return tostring(uuid)
end

local function completeLoadOrder()
    local result = {}
    local seen = {}
    local succeeded, manager = pcall(Ext.Mod.GetModManager)
    local modules = succeeded and manager ~= nil
        and readObjectValue(manager, "LoadOrderedModules") or nil

    if modules ~= nil then
        for _, module in ipairs(modules) do
            local uuid = moduleUuid(module)
            if uuid ~= nil and not seen[uuid] then
                table.insert(result, uuid)
                seen[uuid] = true
            end
        end
    end

    if #result == 0 then
        for _, rawUuid in ipairs(Ext.Mod.GetLoadOrder() or {}) do
            local uuid = tostring(rawUuid)
            if not seen[uuid] then
                table.insert(result, uuid)
                seen[uuid] = true
            end
        end
    end

    return result
end

local function setOf(values)
    local result = {}
    for _, value in ipairs(values or {}) do
        result[tostring(value)] = true
    end
    return result
end

local function loadedBefore(modUuid, statType)
    local succeeded, values = pcall(
        Ext.Stats.GetStatsLoadedBefore, modUuid, statType)
    if not succeeded or values == nil then
        return nil
    end
    return setOf(values)
end

local function collectIntroducedItemStats()
    local loadOrder = completeLoadOrder()
    local introduced = {}
    local failures = {}
    local previousByType = {}

    if #loadOrder == 0 then
        table.insert(failures, "load-order-empty")
        return introduced, loadOrder, failures
    end

    for _, statType in ipairs(ITEM_STAT_TYPES) do
        previousByType[statType] = {}
    end

    for _, rawUuid in ipairs(loadOrder) do
        local modUuid = tostring(rawUuid)
        local currentByType = {}

        for _, statType in ipairs(ITEM_STAT_TYPES) do
            local current = loadedBefore(modUuid, statType)
            if current == nil then
                table.insert(failures,
                    "GetStatsLoadedBefore-failed:" .. modUuid .. ":" .. statType)
                return {}, loadOrder, failures
            end
            currentByType[statType] = current
        end

        if not SOURCE_MOD_EXCLUSIONS[modUuid] and not isOfficialModule(modUuid) then
            local modName, author, directory = moduleInfo(modUuid)
            for _, statType in ipairs(ITEM_STAT_TYPES) do
                for statName in pairs(currentByType[statType]) do
                    if not previousByType[statType][statName]
                        and not BASE_ITEM_STATS[statName] then
                        introduced[statName] = {
                            statType = statType,
                            modUuid = modUuid,
                            modName = modName,
                            author = author,
                            directory = directory
                        }
                    end
                end
            end
        end

        for _, statType in ipairs(ITEM_STAT_TYPES) do
            previousByType[statType] = currentByType[statType]
        end
    end

    return introduced, loadOrder, failures
end

local function categoryExists(statName)
    local categoryName = "I_" .. statName
    local succeeded, category = pcall(
        Ext.Stats.TreasureCategory.GetLegacy, categoryName)
    return succeeded and category ~= nil, categoryName
end

local function statExists(statName)
    local succeeded, stat = pcall(Ext.Stats.Get, statName, nil, false)
    if not succeeded then
        return nil
    end
    return stat
end

local function slotPool(statType, stat)
    if statType == "Shield" then
        return "Shields", "Shield"
    end

    local slot = lower(readStatValue(stat, "Slot"))
    if statType == "Weapon" then
        local properties = lower(readStatValue(stat, "WeaponProperties"))
        if properties:find("twohanded", 1, true)
            or properties:find("two-handed", 1, true) then
            return "Weapons_2H", readStatValue(stat, "Slot")
        end
        return "Weapons_1H", readStatValue(stat, "Slot")
    end

    if slot:find("shield", 1, true) then
        return "Shields", readStatValue(stat, "Slot")
    elseif slot:find("helmet", 1, true) or slot:find("head", 1, true) then
        return "Hats", readStatValue(stat, "Slot")
    elseif slot:find("cloak", 1, true) then
        return "Cloaks", readStatValue(stat, "Slot")
    elseif slot:find("glove", 1, true) then
        return "Gloves", readStatValue(stat, "Slot")
    elseif slot:find("boot", 1, true) then
        return "Boots", readStatValue(stat, "Slot")
    elseif slot:find("amulet", 1, true) then
        return "Amulets", readStatValue(stat, "Slot")
    elseif slot:find("ring", 1, true) then
        return "Rings", readStatValue(stat, "Slot")
    elseif slot:find("breast", 1, true) or slot:find("body", 1, true) then
        local armorType = lower(readStatValue(stat, "ArmorType"))
        if armorType == "" or armorType == "none"
            or armorType:find("cloth", 1, true)
            or armorType:find("clothing", 1, true) then
            return "Clothes", readStatValue(stat, "Slot")
        end
        return "Armor", readStatValue(stat, "Slot")
    end

    return nil, readStatValue(stat, "Slot")
end

local function appendMechanics(
    statName, depth, seen, chunks, referenced, state)
    if depth > MAX_REFERENCE_DEPTH or seen[statName]
        or state.count >= MAX_REFERENCE_STATS then
        return
    end

    local stat = statExists(statName)
    if stat == nil then
        return
    end

    seen[statName] = true
    state.count = state.count + 1
    table.insert(referenced, statName)
    table.insert(chunks, statName)

    for _, field in ipairs(MECHANIC_FIELDS) do
        local value = readStatValue(stat, field)
        if value ~= "" then
            table.insert(chunks, field .. "=" .. value)
            for token in value:gmatch("[%a_][%w_]+") do
                if token:find("_", 1, true) and not seen[token] then
                    appendMechanics(
                        token, depth + 1, seen, chunks, referenced, state)
                end
            end
        end
    end
end

local function itemMechanics(statName)
    local chunks = {}
    local referenced = {}
    appendMechanics(statName, 0, {}, chunks, referenced, { count = 0 })
    return lower(table.concat(chunks, "\n")), referenced
end

local function themeMatches(mechanics)
    local matches = {}
    local reasons = {}

    for theme, rules in pairs(THEME_RULES) do
        local matchCount = 0
        local themeReasons = {}
        for _, rule in ipairs(rules) do
            local term = lower(rule[1])
            if mechanics:find(term, 1, true) then
                matchCount = matchCount + 1
                table.insert(themeReasons, rule[2])
            end
        end
        matches[theme] = matchCount
        reasons[theme] = themeReasons
    end

    return matches, reasons
end

local function addCount(counts, key)
    counts[key] = (counts[key] or 0) + 1
end

local function join(values)
    return #values > 0 and table.concat(values, ",") or "-"
end

local function auditCandidate(statName, source)
    local stat = statExists(statName)
    if stat == nil then
        return nil, "stat-not-readable"
    end

    local rarityRaw = readStatValue(stat, "Rarity")
    local rarity = RARITY_TO_POOL[lower(rarityRaw)]
    if rarity == nil then
        return nil, "rarity-not-supported:" .. rarityRaw
    end

    local rootTemplate = readStatValue(stat, "RootTemplate")
    if rootTemplate == "" or rootTemplate == "00000000-0000-0000-0000-000000000000" then
        return nil, "root-template-missing"
    end
    local templateSucceeded, root = pcall(Ext.Template.GetRootTemplate, rootTemplate)
    if not templateSucceeded or root == nil then
        return nil, "root-template-not-loaded:" .. rootTemplate
    end

    local hasCategory, treasureCategory = categoryExists(statName)
    if not hasCategory then
        return nil, "treasure-category-missing:" .. treasureCategory
    end

    local slotCategory, slot = slotPool(source.statType, stat)
    if slotCategory == nil then
        return nil, "slot-not-supported:" .. slot
    end

    local mechanics, referenced = itemMechanics(statName)
    local matches, reasons = themeMatches(mechanics)
    local categories = { "All", slotCategory }
    local acceptedThemes = {}
    for theme, matchCount in pairs(matches) do
        if matchCount > 0 then
            table.insert(acceptedThemes, theme)
        end
    end
    table.sort(acceptedThemes)
    for _, theme in ipairs(acceptedThemes) do
        table.insert(categories, theme)
    end

    local uniqueRaw = readStatValue(stat, "Unique")
    local uniqueValid = tonumber(uniqueRaw) ~= nil
    local uniqueNormalized = false
    if ENABLE_POOL_MUTATION and not uniqueValid then
        local normalized = pcall(function ()
            stat.Unique = 0
            stat:Sync()
        end)
        if normalized then
            uniqueRaw = readStatValue(stat, "Unique")
            uniqueValid = tonumber(uniqueRaw) ~= nil
            uniqueNormalized = uniqueValid
        end
    end

    return {
        statName = statName,
        source = source,
        rarity = rarity,
        rarityRaw = rarityRaw,
        rootTemplate = rootTemplate,
        treasureCategory = treasureCategory,
        slot = slot,
        slotCategory = slotCategory,
        categories = categories,
        themes = acceptedThemes,
        matches = matches,
        reasons = reasons,
        referenced = referenced,
        uniqueRaw = uniqueRaw,
        uniqueValid = uniqueValid,
        uniqueNormalized = uniqueNormalized
    }, nil
end

local function formatCandidate(candidate)
    local themeDetails = {}
    for _, theme in ipairs(sortedKeys(candidate.matches)) do
        local matchCount = candidate.matches[theme]
        if matchCount > 0 then
            table.insert(themeDetails, string.format(
                "%s[%s]", theme, join(candidate.reasons[theme])))
        end
    end

    return string.format(
        "ITEM\t%s\tmod=%s\tuuid=%s\ttype=%s\trarity=%s(%s)\tslot=%s\tcategory=%s\tpools=%s\tUnique=%s\tUniqueValid=%s\tUniqueNormalized=%s\tthemes=%s\treferences=%s",
        candidate.statName,
        candidate.source.modName,
        candidate.source.modUuid,
        candidate.source.statType,
        candidate.rarity,
        candidate.rarityRaw,
        candidate.slot,
        candidate.treasureCategory,
        join(candidate.categories),
        candidate.uniqueRaw == "" and "<empty>" or candidate.uniqueRaw,
        tostring(candidate.uniqueValid),
        tostring(candidate.uniqueNormalized),
        join(themeDetails),
        join(candidate.referenced))
end

local function targetTableName(rarity, category)
    if category == "All" then
        return "REL_All_" .. rarity
    end
    return "REL_" .. rarity .. "_" .. category
end

local function collectExistingCategories(treasureTable)
    local existing = {}
    for _, subTable in ipairs(treasureTable.SubTables or {}) do
        for _, entry in ipairs(subTable.Categories or {}) do
            local category = entry.TreasureCategory ~= nil
                and tostring(entry.TreasureCategory) or ""
            if category ~= "" then
                existing[category] = true
            end
        end
    end
    return existing
end

local function mutatePools(candidates)
    local requested = {}
    for _, candidate in ipairs(candidates) do
        if candidate.uniqueValid then
            for _, category in ipairs(candidate.categories) do
                local tableName = targetTableName(candidate.rarity, category)
                requested[tableName] = requested[tableName] or {}
                requested[tableName][candidate.treasureCategory] = true
            end
        end
    end

    local result = {
        tablesUpdated = 0,
        entriesAdded = 0,
        entriesExisting = 0,
        failures = {}
    }

    for _, tableName in ipairs(sortedKeys(requested)) do
        local succeeded, treasureTable = pcall(
            Ext.Stats.TreasureTable.GetLegacy, tableName)
        if not succeeded or treasureTable == nil then
            table.insert(result.failures,
                tableName .. ":target-table-not-found")
        elseif treasureTable.SubTables == nil
            or treasureTable.SubTables[1] == nil then
            table.insert(result.failures,
                tableName .. ":target-subtable-not-found")
        else
            local existing = collectExistingCategories(treasureTable)
            local additions = {}
            for _, treasureCategory in ipairs(sortedKeys(requested[tableName])) do
                if existing[treasureCategory] then
                    result.entriesExisting = result.entriesExisting + 1
                else
                    table.insert(additions, treasureCategory)
                end
            end

            if #additions > 0 then
                local targetSubTable = treasureTable.SubTables[1]
                targetSubTable.Categories = targetSubTable.Categories or {}
                for _, treasureCategory in ipairs(additions) do
                    table.insert(targetSubTable.Categories, {
                        Frequency = 1,
                        TreasureCategory = treasureCategory
                    })
                end

                local updated, updateError = pcall(
                    Ext.Stats.TreasureTable.Update, treasureTable)
                if not updated then
                    table.insert(result.failures,
                        tableName .. ":update-failed:" .. tostring(updateError))
                else
                    local verified, updatedTable = pcall(
                        Ext.Stats.TreasureTable.GetLegacy, tableName)
                    local after = verified and updatedTable ~= nil
                        and collectExistingCategories(updatedTable) or {}
                    local missing = {}
                    for _, treasureCategory in ipairs(additions) do
                        if not after[treasureCategory] then
                            table.insert(missing, treasureCategory)
                        end
                    end
                    if #missing > 0 then
                        table.insert(result.failures, tableName
                            .. ":verification-failed:" .. table.concat(missing, ","))
                    else
                        result.tablesUpdated = result.tablesUpdated + 1
                        result.entriesAdded = result.entriesAdded + #additions
                    end
                end
            end
        end
    end

    return result
end

local function runAudit()
    if auditCompleted then
        return
    end
    auditCompleted = true

    local lines = {
        "Patch Relay capsule pool expansion audit",
        "mode=" .. (ENABLE_POOL_MUTATION and "mutation" or "audit-only"),
        "discovery=load-order-owner-diff-minus-base",
        "themeRule=any-mention",
        ""
    }
    local candidates, loadOrder, discoveryFailures =
        collectIntroducedItemStats()
    local accepted = {}
    local rejected = {}
    local countsByMod = {}
    local countsByPool = {}
    local countsByRarity = {}
    local invalidUnique = 0
    local normalizedUnique = 0

    for _, statName in ipairs(sortedKeys(candidates)) do
        local source = candidates[statName]
        local candidate, rejection = auditCandidate(statName, source)
        if candidate ~= nil then
            table.insert(accepted, candidate)
            addCount(countsByMod, candidate.source.modName)
            addCount(countsByRarity, candidate.rarity)
            for _, pool in ipairs(candidate.categories) do
                addCount(countsByPool, candidate.rarity .. "_" .. pool)
            end
            if not candidate.uniqueValid then
                invalidUnique = invalidUnique + 1
            end
            if candidate.uniqueNormalized then
                normalizedUnique = normalizedUnique + 1
            end
        else
            table.insert(rejected, string.format(
                "REJECT\t%s\tmod=%s\tuuid=%s\ttype=%s\treason=%s",
                statName, source.modName, source.modUuid,
                source.statType, rejection))
        end
    end

    local mutation = {
        tablesUpdated = 0,
        entriesAdded = 0,
        entriesExisting = 0,
        failures = {}
    }
    if ENABLE_POOL_MUTATION then
        mutation = mutatePools(accepted)
    end

    table.insert(lines, string.format(
        "SUMMARY\tdiscovered=%d\taccepted=%d\trejected=%d\tinvalidUnique=%d\tnormalizedUnique=%d\tdiscoveryFailures=%d",
        #sortedKeys(candidates), #accepted, #rejected,
        invalidUnique, normalizedUnique, #discoveryFailures))
    table.insert(lines, string.format(
        "MUTATION\ttablesUpdated=%d\tentriesAdded=%d\tentriesExisting=%d\tfailures=%d",
        mutation.tablesUpdated, mutation.entriesAdded,
        mutation.entriesExisting, #mutation.failures))
    for _, failure in ipairs(discoveryFailures) do
        table.insert(lines, "DISCOVERY_FAILURE\t" .. failure)
    end
    for _, failure in ipairs(mutation.failures) do
        table.insert(lines, "MUTATION_FAILURE\t" .. failure)
    end
    table.insert(lines, "LOAD_ORDER_MODULES\t" .. tostring(#loadOrder))
    for index, modUuid in ipairs(loadOrder) do
        local modName = moduleInfo(modUuid)
        table.insert(lines, string.format(
            "LOAD_ORDER\t%d\t%s\t%s", index, modUuid, modName))
    end
    table.insert(lines, "")
    table.insert(lines, "COUNTS_BY_MOD")
    for _, key in ipairs(sortedKeys(countsByMod)) do
        table.insert(lines, key .. "\t" .. tostring(countsByMod[key]))
    end
    table.insert(lines, "")
    table.insert(lines, "COUNTS_BY_RARITY")
    for _, key in ipairs(sortedKeys(countsByRarity)) do
        table.insert(lines, key .. "\t" .. tostring(countsByRarity[key]))
    end
    table.insert(lines, "")
    table.insert(lines, "COUNTS_BY_POOL")
    for _, key in ipairs(sortedKeys(countsByPool)) do
        table.insert(lines, key .. "\t" .. tostring(countsByPool[key]))
    end
    table.insert(lines, "")
    table.insert(lines, "ACCEPTED")
    table.sort(accepted, function (left, right)
        return left.statName < right.statName
    end)
    for _, candidate in ipairs(accepted) do
        table.insert(lines, formatCandidate(candidate))
    end
    table.insert(lines, "")
    table.insert(lines, "REJECTED")
    table.sort(rejected)
    for _, rejection in ipairs(rejected) do
        table.insert(lines, rejection)
    end

    Ext.IO.SaveFile(REPORT_PATH, table.concat(lines, "\n") .. "\n")
    Ext.Utils.Print(string.format(
        "[Patch Relay] Capsule pool expansion: discovered=%d accepted=%d rejected=%d invalidUnique=%d normalizedUnique=%d tablesUpdated=%d entriesAdded=%d discoveryFailures=%d mutationFailures=%d report=%s",
        #sortedKeys(candidates), #accepted, #rejected,
        invalidUnique, normalizedUnique,
        mutation.tablesUpdated, mutation.entriesAdded,
        #discoveryFailures, #mutation.failures, REPORT_PATH))
end

Ext.Events.StatsLoaded:Subscribe(runAudit)
Ext.Events.SessionLoaded:Subscribe(runAudit)
