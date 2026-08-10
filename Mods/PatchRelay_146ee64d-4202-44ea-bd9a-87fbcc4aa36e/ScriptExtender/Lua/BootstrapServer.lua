local MODULE_UUID = "146ee64d-4202-44ea-bd9a-87fbcc4aa36e"
Ext.Require("CapsulePoolExpansion.lua")
local VAR_NAME = "Bindings"
local NULL_GUID = "00000000-0000-0000-0000-000000000000"
local REAPPLY_DELAY_MS = 300
local VERIFY_DELAY_MS = 300
local FINAL_REMOVAL_DELAY_MS = REAPPLY_DELAY_MS + VERIFY_DELAY_MS + 200
local CAPSULE_RECOVERY_DELAY_MS = 150
local CAPSULE_RECOVERY_VERIFY_MS = 250
local CAPSULE_RECOVERY_ENABLED = false
local CAPSULE_SEEDRESET_DELAY_ENABLED = false
local CAPSULE_SEEDRESET_DELAY_MS = 250
local CAPSULE_STATIC_FALLBACK_DELAY_MS = 200
local CAPSULE_STATIC_FALLBACK_VERIFY_MS = 150
local CAPSULE_STATIC_FALLBACK_MAX_ATTEMPTS = 8
local CAPSULE_STATIC_FALLBACK_ENABLED = false
local CAPSULE_REWARD_RARITIES = {
    ["1"] = "Uncommon",
    ["2"] = "Rare",
    ["3"] = "Epic",
    ["4"] = "Legendary"
}
local CAPSULE_REWARD_POOL_THEMES = {
    ["1H"] = "Weapons_1H",
    ["2H"] = "Weapons_2H",
    Amulet = "Amulets",
    Boot = "Boots",
    Cloak = "Cloaks",
    Cloth = "Clothes",
    Generic = "All",
    Glove = "Gloves",
    Hat = "Hats",
    Ring = "Rings",
    Shield = "Shields"
}
local CAPSULE_UNIQUE_STATS = {
    "CRE_BloodOfLathander",
    "DEN_Apprentice_DaggerOfShar",
    "DEN_CapturedGoblin_MurderDagger",
    "DEN_FaithwardenStaff",
    "DEN_TunnelStaff",
    "END_Emperor_Staff",
    "GOB_Torturer_Spear",
    "HAV_MAG_ShadowRending_Dagger",
    "LOW_Elfsong_EmperorSword_LongSword",
    "MAG_Ambusher_Shortsword",
    "MAG_ArcaneAbsorption_Dagger",
    "MAG_BasicEnchanted_Quarterstaff",
    "MAG_BG_BlightBringer_Shortbow",
    "MAG_BG_DragonsBreath_Glaive",
    "MAG_BG_Harmonium_Halberd",
    "MAG_BG_OfAges_Flail",
    "MAG_BG_OfEasthaven_Defender_Flail",
    "MAG_BG_OfTheBanshee_Bow",
    "MAG_BG_Sarevok_OfChaos_Greatsword",
    "MAG_Blindside_Shortsword",
    "MAG_Bonded_Lethal_Longsword",
    "MAG_Bonded_Shocking_Warhammer",
    "MAG_Bonded_Throwing_Battleaxe",
    "MAG_ChargedLightning_Quarterstaff",
    "MAG_Cleric_Devotees_Mace",
    "MAG_Combat_Quarterstaff",
    "MAG_CQCaster_GainArcaneChargeOnDamage_Quarterstaff",
    "MAG_Critical_CriticalCombo_BattleAxe",
    "MAG_Dawn_Morningstar",
    "MAG_DeadShot_Longbow",
    "MAG_Druid_IronWood_Club",
    "MAG_Duergar_Sword_KingsKnife",
    "MAG_Enforcer_NonLethalFright_Club",
    "MAG_Fire_FireDamage_Quarterstaff",
    "MAG_Fire_HeatOnWeaponDamage_Battleaxe",
    "MAG_Fire_IncreasePiercingDamageToBurning_HandCrossbow",
    "MAG_Fire_IncreaseSlashingDamageToBurning_Handaxe",
    "MAG_FlamingFist_FlamingBlade",
    "MAG_FlamingFist_StaffOfFire",
    "MAG_Force_Pike",
    "MAG_FreeCast_Shortsword",
    "MAG_Gandrel_UndeadSlayer_HeavyCrossbow",
    "MAG_Giantslayer_Greatsword",
    "MAG_Githborn_Mindcrusher_Greatsword",
    "MAG_Gortash_HeavyCrossbow",
    "MAG_GreaterNecromancy_Staff",
    "MAG_Harpers_Harmonizing_Rapier",
    "MAG_Harpers_OfWeapons_Quarterstaff",
    "MAG_HigherNecromancy_Staff",
    "MAG_Illithid_Carapace_Armor",
    "MAG_Illithid_MindOverload_Weapon_Longsword",
    "MAG_Justiciar_Scimitar",
    "MAG_LC_BurnOnDamage_Scimitar",
    "MAG_LC_CazadorVampiric_Quarterstaff",
    "MAG_LC_Counterspell_Quarterstaff",
    "MAG_LC_Fleshred_Longsword",
    "MAG_LC_Lorroakan_Quarterstaff",
    "MAG_LC_OfTheFist_MorningStar",
    "MAG_LC_OfTheRam_Quarterstaff",
    "MAG_LC_PirateCommander_Scimitar",
    "MAG_LC_RadiantLight_Rapier",
    "MAG_LC_UndeadSlayer_Crossbow",
    "MAG_Lesser_Infernal_Plate_Armor",
    "MAG_LowHP_IncreaseDamage_Greataxe",
    "MAG_MagicMissile_HandCrossbow",
    "MAG_MeleeDebuff_AttackDebuff1_OnDamage_Helmet",
    "MAG_Mobility_ExplosionOnJump_Maul",
    "MAG_Moonlight_Glaive",
    "MAG_OB_Paladin_DeathKnight_Longsword",
    "MAG_OfAwareness_Bow",
    "MAG_OfRupture_Rapier",
    "MAG_OfSpellPower_Quarterstaff",
    "MAG_Orthon_Hellfire_HandCrossbow",
    "MAG_Paladin_RestoreChannelDivinity_Armor",
    "MAG_PHB_Defender_Greataxe",
    "MAG_PHB_DwarvenThrower_Warhammer",
    "MAG_PHB_OfLifestealing_Shortsword",
    "MAG_PHB_PactKeeper_Quarterstaff",
    "MAG_PoR_OfVigilance_Halberd",
    "MAG_Primeval_Silver_Longsword",
    "MAG_Radiant_Radiating_Hammer",
    "MAG_RadiantLight_Morningstar",
    "MAG_Shadow_Battleaxe",
    "MAG_Shadow_Blinding_Bow",
    "MAG_Shadow_Shortsword",
    "MAG_Slicing_Shortsword",
    "MAG_SpiritualStand_Greataxe",
    "MAG_StrongString_Longbow",
    "MAG_SWA_Roaring_Maul",
    "MAG_TheChromatic_Staff",
    "MAG_TheClover_Scimitar",
    "MAG_TheDestroyer_Maul",
    "MAG_TheDueller_Rapier",
    "MAG_TheThorns_Trident",
    "MAG_TheVictory_Longbow",
    "MAG_Throwable_Pike",
    "MAG_Thunder_ThunderClap_Quarterstaff",
    "MAG_Tyrrant_Warhammer",
    "MAG_Vicious_Battleaxe",
    "MAG_Vicious_Dagger",
    "MAG_Vicious_Shortbow",
    "MAG_Vicious_Shortsword",
    "MAG_Viconia_Mace",
    "MAG_WATCHER_Human_Crossbow",
    "MAG_WATCHER_Human_Greataxe",
    "MAG_WYR_Hellrider_Longbow",
    "MAG_WYRM_Commander_Longsword",
    "MAG_Zhentarim_SleeperDagger",
    "MAG_ZOC_ForceConduit_ChainMail",
    "MAG_ZOC_ForceConduit_Halberd",
    "MOO_WulbrenHammer",
    "ORI_Wyll_Infernal_Rapier",
    "PLA_ConflictedFlind_Flail_Broken",
    "UND_DuergarBlacksmithHammer",
    "UND_DuergarRaft_GruesomeHammer",
    "UND_DuergarRaft_PestKillerAxe",
    "UND_Nere_Sword",
    "UND_SocietyOfBrilliance_ResonanceStaff",
    "UND_StrengthChair_Leg",
    "UND_Tower_StaffBlessMystra",
    "UNI_ARM_Sarevok_Armor",
    "UNI_Bow_SpellslotRecharge",
    "UNI_DoomHammer",
    "UNI_RepeatStaff",
    "UNI_SickleOfBOOOAL",
    "UNI_StaffOfRain",
    "UNI_WYR_Circus_ClownHammer",
    "WPN_Tower_AutomatonHalberd",
    "WYR_Circus_MumblingStaff"
}
local DESTRUCTIVE_REWARD_TIERS = {
    ["1e5acb72-b80d-42d6-8739-f0041101597c"] = "Epic",
    ["3d9fe7e2-9a0e-4ee2-8811-7354d969c9b8"] = "Legendary",
    ["a35d686f-9d74-42f5-87ee-49c73a75d1eb"] = "Primal Epic",
    ["e44d7573-932a-4303-847a-02d2c1324df5"] = "Primal Legendary"
}
local VOID_CAPSULE_TEST_LOG = "PatchRelay/void-capsule-test.log"
local voidCapsuleDoneWindows = {}
local voidCapsuleContainers = {}
local voidCapsuleTraceLines = {}
local voidCapsuleOperations = {}
local voidCapsulePendingRerolls = {}
local capsuleRecoveryOperations = {}
local capsuleRecoveryTemplateOperations = {}
local capsuleRecoveryContainers = {}
local capsuleRecoveryDecoys = {}
local capsuleSeedResetBypass = {}
local capsuleFallbackTemplateOperations = {}
local companionStatuses = {
    PACT_BLADE_NECROTIC = true,
    PACT_BLADE_PSYCHIC = true,
    PACT_BLADE_RADIANT = true
}

Ext.Vars.RegisterModVariable(MODULE_UUID, VAR_NAME, {
    Server = true,
    Client = false,
    Persistent = true
})

local function getBindings()
    local vars = Ext.Vars.GetModVariables(MODULE_UUID)
    return vars, vars[VAR_NAME] or {}
end

local function saveBindings(vars, bindings)
    vars[VAR_NAME] = bindings
end

local function clearCapsuleRewardUniqueness()
    local changed = 0
    local missing = 0
    local failed = 0
    local samples = {}

    for _, statName in ipairs(CAPSULE_UNIQUE_STATS) do
        local stat = Ext.Stats.Get(statName, nil, false)
        if stat == nil then
            missing = missing + 1
        else
            local before = stat.Unique
            local ok, err = pcall(function ()
                stat.Unique = 0
                stat:Sync()
            end)
            if ok then
                changed = changed + 1
                if statName == "MAG_MagicMissile_HandCrossbow"
                    or statName == "MAG_TheClover_Scimitar"
                    or statName == "MAG_TheDueller_Rapier" then
                    table.insert(samples, string.format(
                        "%s:%s->%s", statName, tostring(before), tostring(stat.Unique)))
                end
            else
                failed = failed + 1
                Ext.Utils.PrintError(string.format(
                    "[Patch Relay] Capsule Unique fix failed stat=%s error=%s",
                    statName, tostring(err)))
            end
        end
    end

    local message = string.format(
        "Capsule Unique fix changed=%s missing=%s failed=%s samples=[%s]",
        tostring(changed), tostring(missing), tostring(failed), table.concat(samples, ", "))
    Ext.IO.SaveFile("PatchRelay/capsule-unique-fix.log", message .. "\n")
    Ext.Utils.Print("[Patch Relay] " .. message)
end

local function validOwner(owner)
    return owner ~= nil and owner ~= "" and not string.find(owner, NULL_GUID, 1, true)
end

local function canonicalOwner(owner)
    if not validOwner(owner) then
        return nil
    end

    if #owner >= 36 then
        return string.lower(string.sub(owner, -36))
    end

    return string.lower(owner)
end

local function normalizeBinding(binding)
    if binding.Companion == "PACT_BLADE_WEAPON" then
        binding.Companion = nil
    elseif binding.Companion == nil
        and type(binding.Variant) == "string"
        and companionStatuses[binding.Variant] then
        binding.Companion = binding.Variant
    end
    binding.Owner = canonicalOwner(binding.Owner)
    binding.Variant = nil
    return binding
end

local function removeCompleteBinding(weapon, binding)
    binding = normalizeBinding(binding)
    Osi.RemoveStatus(weapon, "PACT_BLADE", binding.Owner or NULL_GUID)
    if binding.Companion ~= nil then
        Osi.RemoveStatus(weapon, binding.Companion, binding.Owner or NULL_GUID)
    end
end

local function clearPreviousBinding(owner, currentWeapon, bindings)
    owner = canonicalOwner(owner)
    if owner == nil then
        return
    end

    for weapon, binding in pairs(bindings) do
        binding = normalizeBinding(binding)
        if weapon ~= currentWeapon and binding.Owner == owner then
            removeCompleteBinding(weapon, binding)
            bindings[weapon] = nil
        end
    end
end

local function clearBindingsForOwner(owner, reason)
    owner = canonicalOwner(owner)
    if owner == nil then
        return
    end

    local vars, bindings = getBindings()
    local changed = false

    for weapon, binding in pairs(bindings) do
        binding = normalizeBinding(binding)
        if binding.Owner == owner then
            removeCompleteBinding(weapon, binding)
            bindings[weapon] = nil
            changed = true
            Ext.Utils.Print(string.format(
                "[Patch Relay] Cleared inactive owner binding weapon=%s owner=%s reason=%s",
                tostring(weapon), tostring(owner), tostring(reason)))
        end
    end

    if changed then
        saveBindings(vars, bindings)
    end
end

local function rememberAppliedStatus(weapon, status, owner)
    if status ~= "PACT_BLADE" and not companionStatuses[status] then
        return
    end

    local vars, bindings = getBindings()
    local binding = normalizeBinding(bindings[weapon] or {})

    owner = canonicalOwner(owner)
    if owner ~= nil then
        binding.Owner = owner
        clearPreviousBinding(owner, weapon, bindings)
    end

    if status == "PACT_BLADE" then
        binding.Companion = nil
    elseif companionStatuses[status] then
        binding.Companion = status
    end

    bindings[weapon] = binding
    saveBindings(vars, bindings)
end

local function ensureStatus(weapon, status, owner)
    if Osi.HasActiveStatus(weapon, status) ~= 1 then
        Osi.ApplyStatus(weapon, status, -1.0, 1, owner)
    end
end

local function restoreCompleteBinding(weapon)
    local vars, bindings = getBindings()
    local binding = bindings[weapon]
    if binding == nil or not validOwner(binding.Owner) then
        return
    end

    binding = normalizeBinding(binding)
    bindings[weapon] = binding
    saveBindings(vars, bindings)

    ensureStatus(weapon, "PACT_BLADE", binding.Owner)
    if binding.Companion ~= nil then
        ensureStatus(weapon, binding.Companion, binding.Owner)
    end
    Ext.Utils.Print(string.format(
        "[Patch Relay] Restored weapon=%s base=%s companion=%s companionActive=%s",
        tostring(weapon),
        tostring(Osi.HasActiveStatus(weapon, "PACT_BLADE")),
        tostring(binding.Companion),
        tostring(binding.Companion == nil or Osi.HasActiveStatus(weapon, binding.Companion) == 1)))
end

Ext.Osiris.RegisterListener("StatusApplied", 4, "after", function (weapon, status, owner)
    rememberAppliedStatus(weapon, status, owner)
    if status == "PACT_BLADE" or companionStatuses[status] then
        Ext.Utils.Print(string.format(
            "[Patch Relay] Captured weapon=%s status=%s owner=%s",
            tostring(weapon), tostring(status), tostring(owner)))
    end
end)

Ext.Osiris.RegisterListener("StatusRemoved", 4, "after", function (weapon, status)
    if status ~= "PACT_BLADE" and not companionStatuses[status] then
        return
    end

    -- Для обычного пакта StatusRemoved может прийти раньше Unequipped.
    -- Ждём завершения цикла восстановления после снятия и только затем
    -- определяем, было ли удаление окончательным (например, при респеке).
    Ext.Timer.WaitFor(FINAL_REMOVAL_DELAY_MS, function ()
        local vars, bindings = getBindings()
        local binding = bindings[weapon]
        if binding == nil then
            return
        end

        binding = normalizeBinding(binding)
        local baseActive = Osi.HasActiveStatus(weapon, "PACT_BLADE")
        local companionActive = binding.Companion == nil
            or Osi.HasActiveStatus(weapon, binding.Companion) == 1
        if baseActive == 0 or not companionActive then
            bindings[weapon] = nil
            saveBindings(vars, bindings)
            Ext.Utils.Print(string.format(
                "[Patch Relay] Cleared final binding weapon=%s removedStatus=%s base=%s companion=%s companionActive=%s",
                tostring(weapon), tostring(status), tostring(baseActive),
                tostring(binding.Companion), tostring(companionActive)))
        end
    end)
end)

Ext.Osiris.RegisterListener("Unequipped", 2, "after", function (weapon, owner)
    local vars, bindings = getBindings()
    local binding = bindings[weapon]
    if binding == nil then
        Ext.Utils.Print(string.format(
            "[Patch Relay] Unequipped weapon=%s was not tracked",
            tostring(weapon)))
        return
    end

    binding = normalizeBinding(binding)
    local eventOwner = canonicalOwner(owner)
    if binding.Owner ~= nil and eventOwner ~= nil and binding.Owner ~= eventOwner then
        return
    end
    if binding.Owner == nil then
        binding.Owner = eventOwner
    end
    bindings[weapon] = binding
    saveBindings(vars, bindings)
    Ext.Utils.Print(string.format(
        "[Patch Relay] Unequipped tracked weapon=%s owner=%s companion=%s",
        tostring(weapon), tostring(owner), tostring(binding.Companion)))

    Ext.Timer.WaitFor(REAPPLY_DELAY_MS, function ()
        restoreCompleteBinding(weapon)
        Ext.Timer.WaitFor(VERIFY_DELAY_MS, function ()
            restoreCompleteBinding(weapon)
        end)
    end)
end)

Ext.Osiris.RegisterListener("Died", 1, "after", function (owner)
    clearBindingsForOwner(owner, "Died")
end)

Ext.Osiris.RegisterListener("CharacterLeftParty", 1, "after", function (owner)
    clearBindingsForOwner(owner, "CharacterLeftParty")
end)

Ext.Events.SessionLoaded:Subscribe(function ()
    local vars, bindings = getBindings()
    local changed = false

    for weapon, binding in pairs(bindings) do
        binding = normalizeBinding(binding)
        bindings[weapon] = binding
        changed = true

        local weaponExists = Osi.Exists(weapon) == 1
        local ownerExists = validOwner(binding.Owner) and Osi.Exists(binding.Owner) == 1
        local ownerIsPartyMember = ownerExists and Osi.IsPartyMember(binding.Owner, 1) == 1

        if not weaponExists then
            bindings[weapon] = nil
        elseif not ownerIsPartyMember then
            removeCompleteBinding(weapon, binding)
            bindings[weapon] = nil
            Ext.Utils.Print(string.format(
                "[Patch Relay] Cleared stale binding weapon=%s owner=%s ownerExists=%s partyMember=%s",
                tostring(weapon), tostring(binding.Owner), tostring(ownerExists),
                tostring(ownerIsPartyMember)))
        elseif Osi.HasActiveStatus(weapon, "PACT_BLADE") == 1 then
            restoreCompleteBinding(weapon)
        else
            removeCompleteBinding(weapon, binding)
            bindings[weapon] = nil
        end
    end

    if changed then
        saveBindings(vars, bindings)
    end
end)

local function templateGuid(template)
    local value = tostring(template)
    return value:match("([0-9a-fA-F]+%-[0-9a-fA-F]+%-[0-9a-fA-F]+%-[0-9a-fA-F]+%-[0-9a-fA-F]+)$")
        or value
end

local function rewardKey(owner, template)
    return templateGuid(owner) .. "|" .. templateGuid(template)
end

local function rowCount(rows)
    local count = 0
    if rows ~= nil then
        for _ in pairs(rows) do
            count = count + 1
        end
    end
    return count
end

local function traceVoidCapsule(message)
    local line = string.format("[%s] %s", Ext.Timer.ClockTime(), message)
    table.insert(voidCapsuleTraceLines, line)
    Ext.IO.SaveFile(VOID_CAPSULE_TEST_LOG, table.concat(voidCapsuleTraceLines, "\n") .. "\n")
    Ext.Utils.Print("[Patch Relay TEST] " .. message)
end

local function clearCapsuleRecoveryOperation(key, operation)
    capsuleRecoveryOperations[key] = nil
    local templateKey = templateGuid(operation.template)
    if capsuleRecoveryTemplateOperations[templateKey] == operation then
        capsuleRecoveryTemplateOperations[templateKey] = nil
    end
end

local function deleteHeldCapsuleReward(operation, reason)
    local heldItem = operation ~= nil and operation.heldItem or nil
    local heldContainer = operation ~= nil and operation.heldContainer or nil
    operation.heldItem = nil
    operation.heldStat = nil
    operation.heldContainer = nil
    if heldContainer ~= nil then
        pcall(function ()
            Osi.DB_AMP_SeedReset_DecoyCube:Delete(heldContainer)
        end)
    end
    if heldContainer ~= nil and Osi.Exists(heldContainer) == 1 then
        traceVoidCapsule(string.format(
            "Recovery discard held container=%s item=%s reason=%s",
            tostring(heldContainer), tostring(heldItem), tostring(reason)))
        Osi.RequestDelete(heldContainer)
    elseif heldItem ~= nil and Osi.Exists(heldItem) == 1 then
        Osi.RequestDelete(heldItem)
    end
end

local function capsuleTreasureTableName(template)
    local theme, tier = tostring(template):match("^AMP_Capsule_Reward_(.+)_([1-4])_[0-9a-fA-F%-]+$")
    local rarity = tier ~= nil and CAPSULE_REWARD_RARITIES[tier] or nil
    if theme == nil or rarity == nil then
        return nil
    end

    if theme == "Generic" then
        return string.format("REL_All_%s", rarity), rarity
    end

    return string.format(
        "REL_%s_%s", rarity, CAPSULE_REWARD_POOL_THEMES[theme] or theme), rarity
end

local function getSpawnableRootTemplate(statName, expectedRarity)
    local succeeded, stat = pcall(Ext.Stats.Get, statName, nil, false)
    if not succeeded or stat == nil then
        return nil
    end

    local rarity = tostring(stat.Rarity or "")
    if expectedRarity ~= nil and rarity ~= expectedRarity then
        return nil
    end

    local rootTemplate = tostring(stat.RootTemplate or "")
    if rootTemplate == "" or rootTemplate == NULL_GUID then
        return nil
    end

    local templateSucceeded, root = pcall(Ext.Template.GetRootTemplate, rootTemplate)
    if not templateSucceeded or root == nil then
        return nil
    end

    return rootTemplate
end

local function addCapsuleCandidate(candidates, categoryName, statName, weight, expectedRarity)
    local rootTemplate = getSpawnableRootTemplate(statName, expectedRarity)
    if rootTemplate == nil then
        return
    end

    local key = statName .. "|" .. rootTemplate
    local candidate = candidates[key]
    if candidate == nil then
        candidates[key] = {
            category = categoryName,
            stat = statName,
            rootTemplate = rootTemplate,
            weight = weight
        }
    else
        candidate.weight = candidate.weight + weight
    end
end

local function collectCapsuleCandidates(
    tableName, inheritedWeight, candidates, visiting, expectedRarity)
    if visiting[tableName] then
        return
    end
    visiting[tableName] = true

    local succeeded, treasureTable = pcall(Ext.Stats.TreasureTable.GetLegacy, tableName)
    if not succeeded or treasureTable == nil then
        visiting[tableName] = nil
        return
    end

    for _, subTable in ipairs(treasureTable.SubTables or {}) do
        for _, entry in ipairs(subTable.Categories or {}) do
            local entryWeight = inheritedWeight * math.max(1, tonumber(entry.Frequency) or 1)
            local nestedTable = entry.TreasureTable ~= nil and tostring(entry.TreasureTable) or ""
            local categoryName = entry.TreasureCategory ~= nil and tostring(entry.TreasureCategory) or ""

            if nestedTable ~= "" then
                collectCapsuleCandidates(
                    nestedTable, entryWeight, candidates, visiting, expectedRarity)
            elseif categoryName ~= "" then
                local categorySucceeded, category = pcall(
                    Ext.Stats.TreasureCategory.GetLegacy, categoryName)
                if categorySucceeded and category ~= nil then
                    for _, item in ipairs(category.Items or {}) do
                        local statName = tostring(item.Name or "")
                        if statName ~= "" then
                            local itemWeight = entryWeight
                                * math.max(1, tonumber(item.Priority) or 1)
                            addCapsuleCandidate(
                                candidates, categoryName, statName, itemWeight, expectedRarity)
                        end
                    end
                end
            end
        end
    end

    visiting[tableName] = nil
end

local function chooseCapsuleFallback(template, preferredStat)
    local tableName, expectedRarity = capsuleTreasureTableName(template)
    if tableName == nil then
        return nil, nil, "reward-template-not-recognized"
    end

    local byKey = {}
    collectCapsuleCandidates(tableName, 1, byKey, {}, expectedRarity)

    local candidates = {}
    local totalWeight = 0
    for _, candidate in pairs(byKey) do
        totalWeight = totalWeight + candidate.weight
        table.insert(candidates, candidate)
    end

    if totalWeight <= 0 then
        return nil, tableName, "no-spawnable-candidates"
    end

    if preferredStat ~= nil then
        for _, candidate in ipairs(candidates) do
            if candidate.stat == preferredStat then
                return candidate, tableName, nil
            end
        end
    end

    local roll = math.random() * totalWeight
    local cursor = 0
    for _, candidate in ipairs(candidates) do
        cursor = cursor + candidate.weight
        if roll <= cursor then
            return candidate, tableName, nil
        end
    end

    return candidates[#candidates], tableName, nil
end

local capsuleFallbackTables = {}

local function capsuleFallbackTable(candidate)
    local tableName = capsuleFallbackTables[candidate.category]
    if tableName ~= nil then
        return tableName
    end

    tableName = "PatchRelay_CapsuleFallback_"
        .. candidate.category:gsub("[^%w_]", "_")
    local succeeded, err = pcall(Ext.Stats.TreasureTable.Update, {
        Name = tableName,
        MinLevel = 0,
        MaxLevel = 0,
        IgnoreLevelDiff = true,
        UseTreasureGroupContainers = false,
        CanMerge = false,
        SubTables = {
            {
                TotalCount = -1,
                StartLevel = 0,
                EndLevel = 0,
                Categories = {
                    {
                        Frequency = 1,
                        TreasureCategory = candidate.category
                    }
                },
                DropCounts = {}
            }
        }
    })
    if not succeeded then
        traceVoidCapsule(string.format(
            "Recovery singleton table failed category=%s error=%s",
            tostring(candidate.category), tostring(err)))
        return nil
    end

    capsuleFallbackTables[candidate.category] = tableName
    return tableName
end

local capsulePoolAuditScheduled = false

local function auditCapsuleFallbackPools()
    local pools = {}
    local rewardRows = Osi.DB_AMP_VoidCapsule_Reward:Get(nil, nil, nil) or {}
    for _, row in pairs(rewardRows) do
        local template = row[3]
        local tableName = template ~= nil and capsuleTreasureTableName(template) or nil
        if tableName ~= nil then
            pools[tableName] = true
        end
    end

    local poolCount = 0
    local candidateCount = 0
    local emptyPools = {}
    for tableName in pairs(pools) do
        poolCount = poolCount + 1
        local candidates = {}
        collectCapsuleCandidates(tableName, 1, candidates, {}, nil)
        local count = 0
        for _ in pairs(candidates) do
            count = count + 1
        end
        candidateCount = candidateCount + count
        if count == 0 then
            table.insert(emptyPools, tableName)
        end
    end

    table.sort(emptyPools)
    traceVoidCapsule(string.format(
        "Synthetic pool audit pools=%s candidates=%s emptyPools=%s [%s]",
        tostring(poolCount), tostring(candidateCount), tostring(#emptyPools),
        table.concat(emptyPools, ", ")))
end

Ext.Events.SessionLoaded:Subscribe(function ()
    if capsulePoolAuditScheduled then
        return
    end
    capsulePoolAuditScheduled = true
    Ext.Timer.WaitFor(1000, auditCapsuleFallbackPools)
end)

local function checkCapsuleRecoveryContainer(container, state)
    Ext.Timer.WaitFor(CAPSULE_RECOVERY_DELAY_MS, function ()
        local operation = state.operation
        if operation == nil or operation.container ~= container then
            return
        end

        local exists = Osi.Exists(container) == 1
        local empty = false
        if exists then
            local succeeded, result = pcall(function ()
                return Osi.IsInventoryEmpty(container)
            end)
            empty = succeeded and (result == 1 or result == true)
        end

        if state.lootAdded > 0 or (exists and not empty) then
            traceVoidCapsule(string.format(
                "Recovery success owner=%s template=%s mode=native container=%s lootAdded=%s exists=%s empty=%s",
                tostring(operation.owner), tostring(operation.template),
                tostring(container), tostring(state.lootAdded), tostring(exists), tostring(empty)))
            deleteHeldCapsuleReward(operation, "native-success")
            clearCapsuleRecoveryOperation(operation.key, operation)
            capsuleRecoveryContainers[container] = nil
            return
        end

        local heldItem = operation.heldItem
        local heldContainer = operation.heldContainer
        if heldItem == nil or Osi.Exists(heldItem) ~= 1 then
            traceVoidCapsule(string.format(
                "Recovery unavailable owner=%s template=%s container=%s reason=no-held-decoy-item",
                tostring(operation.owner), tostring(operation.template), tostring(container)))
            deleteHeldCapsuleReward(operation, "held-item-missing")
            clearCapsuleRecoveryOperation(operation.key, operation)
            return
        end

        traceVoidCapsule(string.format(
            "Recovery salvage owner=%s template=%s container=%s item=%s stat=%s",
            tostring(operation.owner), tostring(operation.template), tostring(container),
            tostring(heldItem), tostring(operation.heldStat)))

        operation.heldItem = nil
        operation.heldStat = nil
        operation.heldContainer = nil
        Osi.ToInventory(heldItem, container, 1, 0, 0)
        clearCapsuleRecoveryOperation(operation.key, operation)

        Ext.Timer.WaitFor(25, function ()
            if state.lootAdded > 0 then
                if heldContainer ~= nil then
                    pcall(function ()
                        Osi.DB_AMP_SeedReset_DecoyCube:Delete(heldContainer)
                    end)
                    if Osi.Exists(heldContainer) == 1 then
                        Osi.RequestDelete(heldContainer)
                    end
                end
                traceVoidCapsule(string.format(
                    "Recovery salvage transfer confirmed container=%s item=%s source=%s",
                    tostring(container), tostring(heldItem), tostring(heldContainer)))
            else
                traceVoidCapsule(string.format(
                    "Recovery salvage transfer pending container=%s item=%s source=%s",
                    tostring(container), tostring(heldItem), tostring(heldContainer)))
            end
        end)

        Ext.Timer.WaitFor(CAPSULE_RECOVERY_VERIFY_MS, function ()
            local stillExists = Osi.Exists(container) == 1
            local stillEmpty = true
            if stillExists then
                local checkSucceeded, result = pcall(Osi.IsInventoryEmpty, container)
                stillEmpty = not checkSucceeded or result == 1 or result == true
            end
            traceVoidCapsule(string.format(
                "Recovery salvage result container=%s exists=%s empty=%s item=%s",
                tostring(container), tostring(stillExists), tostring(stillEmpty),
                tostring(heldItem)))
            capsuleRecoveryContainers[container] = nil
        end)
    end)
end

local function itemStatsName(item)
    local succeeded, result = pcall(function ()
        local entity = Ext.Entity.Get(item)
        if entity == nil or entity.ServerItem == nil then
            return nil
        end

        if entity.ServerItem.Stats ~= nil then
            return entity.ServerItem.Stats
        end

        if entity.ServerItem.Template ~= nil then
            return entity.ServerItem.Template.Stats
        end

        return nil
    end)

    if not succeeded then
        return "query-error:" .. tostring(result)
    end

    return result
end

local function snapshotContainer(container, delay)
    Ext.Timer.WaitFor(delay, function ()
        local state = voidCapsuleContainers[container]
        local exists = Osi.Exists(container) == 1
        local empty = nil
        if exists then
            local succeeded, result = pcall(function ()
                return Osi.IsInventoryEmpty(container)
            end)
            if succeeded then
                empty = result == 1 or result == true
            else
                empty = "query-error:" .. tostring(result)
            end
        end

        local oldItem = state ~= nil and state.operation ~= nil and state.operation.oldItem or nil
        traceVoidCapsule(string.format(
            "Snapshot delay=%sms tier=%s context=%s container=%s role=%s exists=%s empty=%s oldItem=%s oldExists=%s lootAdded=%s lootRemoved=%s decoyRows=%s rerollInfoRows=%s armedRows=%s deletingRows=%s pendingRows=%s",
            tostring(delay), tostring(state ~= nil and state.tier or nil),
            tostring(state ~= nil and state.operation ~= nil and state.operation.context or nil),
            tostring(container), tostring(state ~= nil and state.role or "unknown"),
            tostring(exists), tostring(empty), tostring(oldItem),
            tostring(oldItem ~= nil and Osi.Exists(oldItem) == 1 or false),
            tostring(state ~= nil and state.lootAdded or 0),
            tostring(state ~= nil and state.lootRemoved or 0),
            tostring(rowCount(Osi.DB_AMP_SeedReset_DecoyCube:Get(container))),
            tostring(rowCount(Osi.DB_AMP_Reroll_ContainerInfo:Get(container, nil, nil))),
            tostring(rowCount(Osi.DB_AMP_Reroll_Armed:Get(container))),
            tostring(rowCount(Osi.DB_AMP_VoidCapsule_Deleting:Get(container))),
            tostring(state ~= nil and rowCount(Osi.DB_AMP_VoidCapsule_PendingReward:Get(
                state.owner, nil, state.template, nil)) or 0)))

        if delay == 2000 and not exists then
            voidCapsuleContainers[container] = nil
        end
    end)
end

Ext.Osiris.RegisterListener(
    "PROC_AMP_SeedReset_Done", 2, "before",
    function (owner, template)
        if not CAPSULE_SEEDRESET_DELAY_ENABLED then
            return
        end

        local key = rewardKey(owner, template)
        if capsuleSeedResetBypass[key] then
            capsuleSeedResetBypass[key] = nil
            traceVoidCapsule(string.format(
                "SeedReset delay release owner=%s template=%s",
                tostring(owner), tostring(template)))
            return
        end

        local tagRows = Osi.DB_AMP_VoidCapsule_SeedReset_TagPending:Get(
            nil, owner, template) or {}
        if rowCount(tagRows) == 0 then
            return
        end

        local delayedTags = {}
        for _, row in pairs(tagRows) do
            local tag = row[1]
            table.insert(delayedTags, tag)
            Osi.DB_AMP_VoidCapsule_SeedReset_TagPending:Delete(
                tag, owner, template)
        end

        traceVoidCapsule(string.format(
            "SeedReset delay intercept owner=%s template=%s tags=%s delayMs=%s",
            tostring(owner), tostring(template), table.concat(delayedTags, ","),
            tostring(CAPSULE_SEEDRESET_DELAY_MS)))

        Ext.Timer.WaitFor(CAPSULE_SEEDRESET_DELAY_MS, function ()
            local restored = 0
            for _, tag in ipairs(delayedTags) do
                local deferredRows = Osi.DB_AMP_VoidCapsule_DeferredSpawn:Get(
                    tag, owner, nil, template, nil) or {}
                if rowCount(deferredRows) > 0 then
                    Osi.DB_AMP_VoidCapsule_SeedReset_TagPending(
                        tag, owner, template)
                    restored = restored + 1
                end
            end

            if restored == 0 then
                traceVoidCapsule(string.format(
                    "SeedReset delay cancelled owner=%s template=%s reason=no-deferred-row",
                    tostring(owner), tostring(template)))
                return
            end

            capsuleSeedResetBypass[key] = true
            Osi.PROC_AMP_SeedReset_Done(owner, template)
        end)
    end)

Ext.Osiris.RegisterListener(
    "PROC_AMP_SeedReset_Done", 2, "before",
    function (owner, template)
        local guid = templateGuid(template)
        local tier = DESTRUCTIVE_REWARD_TIERS[guid]
        if tier == nil then
            return
        end

        local key = rewardKey(owner, guid)
        voidCapsuleDoneWindows[key] = template
        traceVoidCapsule(string.format(
            "Done before tier=%s owner=%s template=%s tagRows=%s deferredRows=%s",
            tostring(tier), tostring(owner), tostring(template),
            tostring(rowCount(Osi.DB_AMP_VoidCapsule_SeedReset_TagPending:Get(nil, owner, template))),
            tostring(rowCount(Osi.DB_AMP_VoidCapsule_DeferredSpawn:Get(nil, owner, nil, template, nil)))))
    end)

Ext.Osiris.RegisterListener("AddedTo", 3, "before", function (item, inventoryHolder)
    local holderTemplate = Osi.GetTemplate(inventoryHolder)
    local holderTier = holderTemplate ~= nil and DESTRUCTIVE_REWARD_TIERS[templateGuid(holderTemplate)] or nil
    if holderTier ~= nil then
        local state = voidCapsuleContainers[inventoryHolder]
        if state == nil then
            state = { role = "unclassified", lootAdded = 0, lootRemoved = 0 }
            voidCapsuleContainers[inventoryHolder] = state
        end
        state.lootAdded = state.lootAdded + 1
        traceVoidCapsule(string.format(
            "Loot AddedTo tier=%s item=%s stats=%s itemTemplate=%s container=%s decoyRowsAtAdd=%s",
            tostring(holderTier), tostring(item), tostring(itemStatsName(item)),
            tostring(Osi.GetTemplate(item)), tostring(inventoryHolder),
            tostring(rowCount(Osi.DB_AMP_SeedReset_DecoyCube:Get(inventoryHolder)))))
    end

    local template = Osi.GetTemplate(item)
    local tier = template ~= nil and DESTRUCTIVE_REWARD_TIERS[templateGuid(template)] or nil
    if tier == nil then
        return
    end

    local key = rewardKey(inventoryHolder, templateGuid(template))
    local pendingRows = rowCount(Osi.DB_AMP_VoidCapsule_PendingReward:Get(
        inventoryHolder, nil, template, nil))
    local state = voidCapsuleContainers[item] or { lootAdded = 0, lootRemoved = 0 }
    state.owner = inventoryHolder
    state.template = template
    state.container = item
    state.tier = tier
    state.operation = voidCapsuleOperations[key]
    if pendingRows > 0 then
        state.role = "final"
    else
        state.role = "decoy-or-unexpected"
    end
    voidCapsuleContainers[item] = state

    traceVoidCapsule(string.format(
        "Container AddedTo tier=%s owner container=%s owner=%s role=%s spawningRows=%s activeRows=%s decoyRows=%s pendingRows=%s lootAddedBeforeOwner=%s oldItem=%s oldExists=%s",
        tostring(tier), tostring(item), tostring(inventoryHolder), tostring(state.role),
        tostring(rowCount(Osi.DB_AMP_SeedReset_Spawning:Get(1))),
        tostring(rowCount(Osi.DB_AMP_SeedReset_Active:Get(inventoryHolder, template, nil))),
        tostring(rowCount(Osi.DB_AMP_SeedReset_DecoyCube:Get(item))), tostring(pendingRows),
        tostring(state.lootAdded),
        tostring(state.operation ~= nil and state.operation.oldItem or nil),
        tostring(state.operation ~= nil and state.operation.oldItem ~= nil
            and Osi.Exists(state.operation.oldItem) == 1 or false)))

    snapshotContainer(item, 100)
    snapshotContainer(item, 500)
    snapshotContainer(item, 1000)
    snapshotContainer(item, 2000)
end)

Ext.Osiris.RegisterListener(
    "PROC_AMP_VoidCapsule_RerollStart", 3, "before",
    function (item, capsule, owner)
        voidCapsulePendingRerolls[templateGuid(owner)] = item
        traceVoidCapsule(string.format(
            "RerollStart before item=%s template=%s capsule=%s owner=%s itemInfoRows=%s",
            tostring(item), tostring(Osi.GetTemplate(item)), tostring(capsule), tostring(owner),
            tostring(rowCount(Osi.DB_AMP_Reroll_ItemInfo:Get(item, nil, nil)))))
    end)

Ext.Osiris.RegisterListener(
    "PROC_AMP_VoidCapsule_SpawnReward", 4, "before",
    function (owner, context, template, capsule)
        if CAPSULE_STATIC_FALLBACK_ENABLED then
            capsuleFallbackTemplateOperations[templateGuid(template)] = {
                owner = owner,
                context = context,
                template = template,
                capsule = capsule,
                lastDecoyStat = nil,
                finalContainer = nil,
                finalLootAdded = 0,
                triedStats = {}
            }
        end

        if not CAPSULE_RECOVERY_ENABLED then
            return
        end

        local recoveryKey = rewardKey(owner, template)
        local recoveryOperation = capsuleRecoveryOperations[recoveryKey]
        if recoveryOperation == nil then
            recoveryOperation = {
                key = recoveryKey,
                owner = owner,
                context = context,
                template = template,
                capsule = capsule,
                lastDecoyStat = nil,
                heldItem = nil,
                heldStat = nil,
                heldContainer = nil,
                container = nil
            }
            capsuleRecoveryOperations[recoveryKey] = recoveryOperation
        else
            deleteHeldCapsuleReward(recoveryOperation, "operation-restarted")
            recoveryOperation.owner = owner
            recoveryOperation.template = template
            recoveryOperation.capsule = capsule
            recoveryOperation.lastDecoyStat = nil
            recoveryOperation.container = nil
        end
        capsuleRecoveryTemplateOperations[templateGuid(template)] = recoveryOperation

        local tier = DESTRUCTIVE_REWARD_TIERS[templateGuid(template)]
        if tier ~= nil then
            local ownerGuid = templateGuid(owner)
            voidCapsuleOperations[rewardKey(owner, template)] = {
                owner = owner,
                context = context,
                template = template,
                capsule = capsule,
                tier = tier,
                oldItem = context == "Reroll" and voidCapsulePendingRerolls[ownerGuid] or nil
            }
            voidCapsulePendingRerolls[ownerGuid] = nil
            traceVoidCapsule(string.format(
                "SpawnReward tier=%s owner=%s context=%s template=%s capsule=%s oldItem=%s oldExists=%s",
                tostring(tier), tostring(owner), tostring(context), tostring(template), tostring(capsule),
                tostring(voidCapsuleOperations[rewardKey(owner, template)].oldItem),
                tostring(voidCapsuleOperations[rewardKey(owner, template)].oldItem ~= nil
                    and Osi.Exists(voidCapsuleOperations[rewardKey(owner, template)].oldItem) == 1 or false)))
        end
    end)

local function runStaticCapsuleFallback(container, templateKey, operation, attempt)
    if capsuleFallbackTemplateOperations[templateKey] ~= operation then
        return
    end

    if operation.finalLootAdded > 0 then
        traceVoidCapsule(string.format(
            "Static fallback native success container=%s template=%s lootAdded=%s",
            tostring(container), tostring(operation.template),
            tostring(operation.finalLootAdded)))
        capsuleFallbackTemplateOperations[templateKey] = nil
        return
    end

    if Osi.Exists(container) ~= 1 then
        traceVoidCapsule(string.format(
            "Static fallback stopped container=%s template=%s reason=container-missing",
            tostring(container), tostring(operation.template)))
        capsuleFallbackTemplateOperations[templateKey] = nil
        return
    end

    local stat = attempt == 1 and operation.lastDecoyStat or nil
    if stat == nil or operation.triedStats[stat] then
        for _ = 1, 32 do
            local candidate = chooseCapsuleFallback(operation.template, nil)
            if candidate == nil then
                break
            end
            if not operation.triedStats[candidate.stat] then
                stat = candidate.stat
                break
            end
        end
    end

    if stat == nil then
        traceVoidCapsule(string.format(
            "Static fallback unavailable container=%s template=%s attempt=%s reason=no-untried-category",
            tostring(container), tostring(operation.template), tostring(attempt)))
        capsuleFallbackTemplateOperations[templateKey] = nil
        return
    end

    operation.triedStats[stat] = true
    local tableName = "PRC_" .. stat
    local level = 1
    pcall(function ()
        level = Osi.GetLevel(operation.owner) or 1
    end)
    local tableLoaded = false
    pcall(function ()
        tableLoaded = Ext.Stats.TreasureTable.GetLegacy(tableName) ~= nil
    end)
    traceVoidCapsule(string.format(
        "Static fallback generate container=%s table=%s tableLoaded=%s stat=%s owner=%s level=%s attempt=%s",
        tostring(container), tostring(tableName), tostring(tableLoaded),
        tostring(stat), tostring(operation.owner), tostring(level), tostring(attempt)))
    Osi.GenerateTreasure(container, tableName, level, operation.owner)

    Ext.Timer.WaitFor(CAPSULE_STATIC_FALLBACK_VERIFY_MS, function ()
        if capsuleFallbackTemplateOperations[templateKey] ~= operation then
            return
        end
        if operation.finalLootAdded > 0 then
            traceVoidCapsule(string.format(
                "Static fallback result container=%s table=%s attempt=%s lootAdded=%s success=true",
                tostring(container), tostring(tableName), tostring(attempt),
                tostring(operation.finalLootAdded)))
            capsuleFallbackTemplateOperations[templateKey] = nil
        elseif attempt < CAPSULE_STATIC_FALLBACK_MAX_ATTEMPTS then
            traceVoidCapsule(string.format(
                "Static fallback result container=%s table=%s attempt=%s lootAdded=0 success=false retry=true",
                tostring(container), tostring(tableName), tostring(attempt)))
            runStaticCapsuleFallback(container, templateKey, operation, attempt + 1)
        else
            traceVoidCapsule(string.format(
                "Static fallback exhausted container=%s template=%s attempts=%s",
                tostring(container), tostring(operation.template), tostring(attempt)))
            capsuleFallbackTemplateOperations[templateKey] = nil
        end
    end)
end

Ext.Osiris.RegisterListener("AddedTo", 3, "after", function (item, inventoryHolder)
    local holderTemplate = Osi.GetTemplate(inventoryHolder)
    if holderTemplate ~= nil then
        local fallbackOperation = capsuleFallbackTemplateOperations[templateGuid(holderTemplate)]
        if fallbackOperation ~= nil then
            if fallbackOperation.finalContainer == inventoryHolder then
                fallbackOperation.finalLootAdded = fallbackOperation.finalLootAdded + 1
            else
                local decoyRows = rowCount(Osi.DB_AMP_SeedReset_DecoyCube:Get(inventoryHolder))
                local rerollInfoRows = rowCount(
                    Osi.DB_AMP_Reroll_ContainerInfo:Get(inventoryHolder, nil, nil))
                if decoyRows == 0 and rerollInfoRows > 0 then
                    fallbackOperation.finalContainer = inventoryHolder
                    fallbackOperation.finalLootAdded = fallbackOperation.finalLootAdded + 1
                elseif decoyRows > 0 then
                local generatedStat = itemStatsName(item)
                if generatedStat ~= nil and not tostring(generatedStat):find("query%-error:") then
                    fallbackOperation.lastDecoyStat = tostring(generatedStat)
                    traceVoidCapsule(string.format(
                        "Static fallback captured decoy stat=%s container=%s template=%s",
                        tostring(generatedStat), tostring(inventoryHolder),
                        tostring(fallbackOperation.template)))
                end
                end
            end
        end

        local holderOperation = capsuleRecoveryTemplateOperations[templateGuid(holderTemplate)]
        if holderOperation ~= nil then
            local holderState = capsuleRecoveryContainers[inventoryHolder]
                or { lootAdded = 0, operation = holderOperation }
            holderState.lootAdded = holderState.lootAdded + 1
            holderState.operation = holderOperation
            capsuleRecoveryContainers[inventoryHolder] = holderState

            if rowCount(Osi.DB_AMP_SeedReset_DecoyCube:Get(inventoryHolder)) > 0 then
                local generatedStat = itemStatsName(item)
                if generatedStat ~= nil and not tostring(generatedStat):find("query%-error:") then
                    holderOperation.lastDecoyStat = tostring(generatedStat)
                    traceVoidCapsule(string.format(
                        "Recovery captured decoy stat=%s container=%s template=%s",
                        tostring(generatedStat), tostring(inventoryHolder),
                        tostring(holderOperation.template)))

                    capsuleRecoveryDecoys[inventoryHolder] = {
                        operation = holderOperation,
                        item = item,
                        stat = tostring(generatedStat)
                    }
                    traceVoidCapsule(string.format(
                        "Recovery queued decoy extraction container=%s item=%s stat=%s owner=%s",
                        tostring(inventoryHolder), tostring(item), tostring(generatedStat),
                        tostring(holderOperation.owner)))
                end
            end
        end
    end

    local template = Osi.GetTemplate(item)
    if template == nil then
        return
    end

    local fallbackTemplateKey = templateGuid(template)
    local fallbackOperation = capsuleFallbackTemplateOperations[fallbackTemplateKey]
    if fallbackOperation ~= nil then
        Ext.Timer.WaitFor(75, function ()
            if capsuleFallbackTemplateOperations[fallbackTemplateKey] ~= fallbackOperation
                or Osi.Exists(item) ~= 1 then
                return
            end

            local decoyRows = rowCount(Osi.DB_AMP_SeedReset_DecoyCube:Get(item))
            local rerollInfoRows = rowCount(Osi.DB_AMP_Reroll_ContainerInfo:Get(item, nil, nil))
            if decoyRows > 0 or rerollInfoRows == 0 then
                return
            end

            if fallbackOperation.finalContainer ~= item then
                fallbackOperation.finalContainer = item
                fallbackOperation.finalLootAdded = 0
            end

            Ext.Timer.WaitFor(CAPSULE_STATIC_FALLBACK_DELAY_MS, function ()
                if capsuleFallbackTemplateOperations[fallbackTemplateKey] ~= fallbackOperation
                    or Osi.Exists(item) ~= 1 then
                    return
                end
                runStaticCapsuleFallback(item, fallbackTemplateKey, fallbackOperation, 1)
            end)
        end)
    end

    local operationKey = rewardKey(inventoryHolder, template)
    local operation = capsuleRecoveryOperations[operationKey]
    if operation == nil then
        return
    end

    -- PendingReward alone is not enough: the last SeedReset decoy can reach
    -- AddedTo after PendingReward was inserted.  Classify only after Ancient
    -- has marked the real container for rerolls and the decoy marker is absent.
    Ext.Timer.WaitFor(75, function ()
        local currentOperation = capsuleRecoveryOperations[operationKey]
        if currentOperation ~= operation or Osi.Exists(item) ~= 1 then
            return
        end

        local decoyRows = rowCount(Osi.DB_AMP_SeedReset_DecoyCube:Get(item))
        local rerollInfoRows = rowCount(Osi.DB_AMP_Reroll_ContainerInfo:Get(item, nil, nil))
        if decoyRows > 0 or rerollInfoRows == 0 then
            traceVoidCapsule(string.format(
                "Recovery ignored non-final container=%s decoyRows=%s rerollInfoRows=%s",
                tostring(item), tostring(decoyRows), tostring(rerollInfoRows)))
            return
        end

        local state = capsuleRecoveryContainers[item]
            or { lootAdded = 0, operation = operation }
        state.operation = operation
        capsuleRecoveryContainers[item] = state
        operation.container = item

        traceVoidCapsule(string.format(
            "Recovery final owner=%s template=%s mode=native container=%s lootAddedBeforeOwner=%s decoyRows=%s rerollInfoRows=%s",
            tostring(operation.owner), tostring(operation.template), tostring(item),
            tostring(state.lootAdded), tostring(decoyRows), tostring(rerollInfoRows)))
        checkCapsuleRecoveryContainer(item, state)
    end)
end)

Ext.Osiris.RegisterListener("ObjectTimerFinished", 2, "before", function (object, timer)
    if timer ~= "AMP_SeedReset_DelayedDelete" then
        return
    end

    local decoy = capsuleRecoveryDecoys[object]
    capsuleRecoveryDecoys[object] = nil
    if decoy == nil or decoy.operation == nil or Osi.Exists(decoy.item) ~= 1 then
        return
    end

    local operation = decoy.operation
    local previousItem = operation.heldItem
    if previousItem ~= nil and previousItem ~= decoy.item and Osi.Exists(previousItem) == 1 then
        Osi.RequestDelete(previousItem)
    end

    Osi.ToInventory(decoy.item, operation.owner, 1, 0, 0)
    operation.heldItem = decoy.item
    operation.heldStat = decoy.stat
    operation.heldContainer = nil
    traceVoidCapsule(string.format(
        "Recovery extract before delete container=%s item=%s stat=%s owner=%s",
        tostring(object), tostring(decoy.item), tostring(decoy.stat),
        tostring(operation.owner)))

    Ext.Timer.WaitFor(25, function ()
        local inventoryOwner = nil
        if Osi.Exists(decoy.item) == 1 then
            pcall(function ()
                inventoryOwner = Osi.GetInventoryOwner(decoy.item)
            end)
        end
        traceVoidCapsule(string.format(
            "Recovery extract result container=%s containerExists=%s item=%s itemExists=%s inventoryOwner=%s",
            tostring(object), tostring(Osi.Exists(object) == 1), tostring(decoy.item),
            tostring(Osi.Exists(decoy.item) == 1), tostring(inventoryOwner)))
    end)
end)

Ext.Osiris.RegisterListener("RemovedFrom", 2, "after", function (item, inventoryHolder)
    local state = voidCapsuleContainers[inventoryHolder]
    if state == nil then
        local holderTemplate = Osi.GetTemplate(inventoryHolder)
        if holderTemplate == nil or DESTRUCTIVE_REWARD_TIERS[templateGuid(holderTemplate)] == nil then
            return
        end
        state = { role = "unclassified", lootAdded = 0, lootRemoved = 0 }
        voidCapsuleContainers[inventoryHolder] = state
    end

    state.lootRemoved = state.lootRemoved + 1
    traceVoidCapsule(string.format(
        "Loot RemovedFrom tier=%s item=%s itemTemplate=%s container=%s role=%s",
        tostring(state.tier), tostring(item), tostring(Osi.GetTemplate(item)),
        tostring(inventoryHolder), tostring(state.role)))
end)

Ext.Osiris.RegisterListener(
    "PROC_AMP_SeedReset_Done", 2, "after",
    function (owner, template)
        local guid = templateGuid(template)
        local tier = DESTRUCTIVE_REWARD_TIERS[guid]
        if tier == nil then
            return
        end

        traceVoidCapsule(string.format(
            "Done after tier=%s owner=%s template=%s pendingRows=%s",
            tostring(tier), tostring(owner), tostring(template),
            tostring(rowCount(Osi.DB_AMP_VoidCapsule_PendingReward:Get(owner, nil, template, nil)))))
        voidCapsuleDoneWindows[rewardKey(owner, guid)] = nil
    end)

traceVoidCapsule(string.format(
    "Epic-vs-Legendary diagnostic-only build loaded extender=%s game=%s",
    tostring(Ext.Utils.Version()), tostring(Ext.Utils.GameVersion())))

Ext.Utils.Print("[Patch Relay] Pact weapon effect handler loaded")
Ext.Utils.Print("[Patch Relay TEST] Epic-vs-Legendary diagnostic-only handler loaded")
