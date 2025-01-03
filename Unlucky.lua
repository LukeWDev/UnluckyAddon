Unlucky = {
    isActive = false,
    playerClass = nil,
    playerSpec = nil,
    playerSpells = {},
    abilityTracker = AbilityTracker.new(),
    deathTime = nil,
    excuseGenerator = ExcuseGenerator.new(),
    eventListener = nil
}

function Unlucky:OnEventAddonLoaded(addOnName)
    if addOnName ~= "Unlucky" then return end
    CORE:Log("Addon Loaded")
    Unlucky.isActive = Unlucky:RefreshPlayerData()
    if Unlucky.isActive then
        Unlucky:BindEvents()
    else    
        Unlucky.eventListener:UnregisterAllEvents()
    end
end

-- assign the OnLoadFunction
Unlucky.eventListener = EventListener.new(Unlucky.OnEventAddonLoaded)

function Unlucky:BindEvents()
    self.eventListener:RegisterEvent("PLAYER_DEAD", Unlucky.OnEventPlayerDead)
    --self.eventListener:RegisterEvent("UNIT_AURA", Unlucky.OnEventPlayerDead)
    --self.eventListener:RegisterEvent("PLAYER_REGEN_ENABLED", Unlucky.OnEventPlayerDead)
    --self.eventListener:RegisterEvent("PLAYER_REGEN_DISABLED", Unlucky.OnEventPlayerDead)
    --self.eventListener:RegisterEvent("PLAYER_TALENT_UPDATE", Unlucky.OnEventPlayerDead)
    --self.eventListener:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Unlucky.OnEventPlayerDead)
end

function Unlucky:RefreshPlayerData()
    CORE:Log("Refreshing Player Data")
    Unlucky.playerClass = UnitClass("player")
    local _, spec = GetSpecializationInfo(GetSpecialization())
    Unlucky.playerSpec = spec
    -- TODO get racial spells
    -- TODO get items (potion, healthstone)
    Unlucky.playerSpells = GetClassSpells(Unlucky.playerClass, Unlucky.playerSpec)
    return #Unlucky.playerSpells > 0
end

function Unlucky:OnEventPlayerDead()
    Unlucky.deathTime = CORE:GetCurrentTime()
    print("Deadge " .. Unlucky.playerClass .. " at " .. Unlucky.deathTime)
    local activeBuffs, recentDamage = Unlucky.abilityTracker:GetData()
    local availableSpells = {}
    for spellName, spell in pairs(Unlucky.playerSpells) do
        if (not spell:IsActive(activeBuffs) and not spell:IsOnCooldown()) then
            availableSpells[spellName] = spell
        end
    end
    local highestDamageType = Unlucky:DetermineDeathOutcome(recentDamage)
    local helpfulSpells = Unlucky:FindAvailableSpells(availableSpells, highestDamageType)
    local excuse = ExcuseGenerator:GenerateExcuse()
    -- update any ui
end

function Unlucky:DetermineDeathOutcome(recentDamage)
    -- check if was stunned/rooted? (for racial spells)
    return DamageType.ALL
end

function Unlucky:FindAvailableSpells(availableSpells, damageType)
    local helpfulSpells = {}
    for spellName, spell in pairs(availableSpells) do
        if spell:IsMatchingDamageType(damageType) then
            print(spellName .. " is matching damage type " .. tostring(damageType))
            helpfulSpells[spellName] = spell
        end
    end
    return helpfulSpells
end

function Unlucky:OnEventPlayerEnteredCombat()
    self.abilityTracker:StartDamageTracker()
end

function Unlucky:OnEventPlayerExitedCombat()
    self.abilityTracker:StopDamageTracker()
end

function Unlucky:OnEventPlayerAuraAdded(auraInfo)
    if Unlucky.playerSpells[auraInfo.name] == nil then return end -- only track class spells
    Unlucky.abilityTracker:RegisterBuff(auraInfo.auraInstanceID, auraInfo.name, auraInfo.expirationTime)
end

function Unlucky:OnEventPlayerAuraRemoved(auraInstanceID)
    Unlucky.abilityTracker:UnRegisterBuff(auraInstanceID)
end

-- FOR OFFLINE USE TO GET THE NODE ID
function GetTalentNodeID(talentName)

    local configID = C_ClassTalents.GetActiveConfigID()
    if configID == nil then return end

    local configInfo = C_Traits.GetConfigInfo(configID)
    if configInfo == nil then return end

    for _, treeID in ipairs(configInfo.treeIDs) do -- in the context of talent trees, there is only 1 treeID
        local nodes = C_Traits.GetTreeNodes(treeID)
        for i, nodeID in ipairs(nodes) do
            local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
            for _, entryID in ipairs(nodeInfo.entryIDs) do -- each node can have multiple entries (e.g. choice nodes have 2)
                local entryInfo = C_Traits.GetEntryInfo(configID, entryID)
                if entryInfo and entryInfo.definitionID then
                    local definitionInfo = C_Traits.GetDefinitionInfo(entryInfo.definitionID)
                    if definitionInfo.spellID then
                        local info = C_Spell.GetSpellInfo(definitionInfo.spellID)
                        if info.name == talentName then
                            return nodeID
                        end
                    end
                end
            end
        end
    end
    return nil
end