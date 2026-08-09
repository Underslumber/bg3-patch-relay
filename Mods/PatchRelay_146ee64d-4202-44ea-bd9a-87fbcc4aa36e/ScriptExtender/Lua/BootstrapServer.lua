local MODULE_UUID = "146ee64d-4202-44ea-bd9a-87fbcc4aa36e"
local VAR_NAME = "Bindings"
local NULL_GUID = "00000000-0000-0000-0000-000000000000"
local REAPPLY_DELAY_MS = 300
local VERIFY_DELAY_MS = 300
local FINAL_REMOVAL_DELAY_MS = REAPPLY_DELAY_MS + VERIFY_DELAY_MS + 200
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

Ext.Utils.Print("[Patch Relay] Pact weapon effect handler loaded")
