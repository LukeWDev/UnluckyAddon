local eventListenerFrame = CreateFrame("Frame", "UnluckyListenerFrame", UIParent)
function eventListenerFrame:OnEvent(event, ...)
    self[event](self, event, ...)
end

function eventListenerFrame:ADDON_LOADED(event, addOnName)
    if addOnName == "Unlucky" then
        Unlucky:OnEventAddonLoaded()
    end
end

function eventListenerFrame:PLAYER_TALENT_UPDATE()
    Unlucky:RefreshPlayerData()
end

function eventListenerFrame:PLAYER_DEAD()
    Unlucky:OnEventPlayerDead()
end

function eventListenerFrame:COMBAT_LOG_EVENT_UNFILTERED(event)
    local timestamp, subevent, _, _, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
    -- check if the target unit is the player
    local playerName, _ = UnitName("player")
    if not playerName == destName then
        return
    end
    -- check if source is NOT friendly
    if bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0 then
        return
    end
    local environmentalType, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing
    local spellId, spellName, spellSchool
    if subevent == "SWING_DAMAGE" then
        amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(12, CombatLogGetCurrentEventInfo())
    elseif subevent == "ENVIRONMENTAL_DAMAGE" then
        environmentalType, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(12, CombatLogGetCurrentEventInfo())
    else -- RANGE_DAMAGE, SPELL_DAMAGE, and SPELL_PERIODIC_DAMAGE
        spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(12, CombatLogGetCurrentEventInfo())
    end
end

function eventListenerFrame:UNIT_AURA(_, unitTarget, updateInfo)
    if not updateInfo then return end
    if unitTarget ~= "player" then
        return
    end
    if updateInfo.addedAuras then
        for _, addedAura in ipairs(updateInfo.addedAuras) do
            if addedAura.sourceUnit == "player" then
                Unlucky:OnEventPlayerAuraAdded(addedAura)
            end
        end
    end
    if updateInfo.removedAuraInstanceIDs then
        for _, removedAuraID in ipairs(updateInfo.removedAuraInstanceIDs) do
            Unlucky:OnEventPlayerAuraRemoved(removedAuraID)
        end
    end
end

function eventListenerFrame:PLAYER_REGEN_DISABLED()
    CORE:Log("Entered Combat")
    Unlucky:OnEventPlayerEnteredCombat()
end

function eventListenerFrame:PLAYER_REGEN_ENABLED()
    CORE:Log("Exited Combat")
    Unlucky:OnEventPlayerExitedCombat()
end

function IsSourceFriendly(flags)
    return bit.band(flags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0
end

eventListenerFrame:RegisterEvent("ADDON_LOADED")
eventListenerFrame:RegisterEvent("PLAYER_DEAD")
eventListenerFrame:RegisterEvent("UNIT_AURA")
eventListenerFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventListenerFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventListenerFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
--eventListenerFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventListenerFrame:SetScript("OnEvent", eventListenerFrame.OnEvent)



-- TEST SLASH COMMANDS
SLASH_MYADDON1 = "/unlucky"
SLASH_MYADDON2 = "/ul"
SlashCmdList["MYADDON"] = function ()
    eventListenerFrame:PLAYER_DEAD()
end