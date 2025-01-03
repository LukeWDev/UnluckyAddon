-- class that should track the last x damage sources that a player recieves
Buff = {}
Buff.__index = Buff

function Buff.new(name, expirationTime)
    local self = setmetatable({}, Buff)
    self.name = name
    self.expirationTime = expirationTime
    return self
end

AbilityTracker = {}
AbilityTracker.__index = AbilityTracker

function AbilityTracker.new()
    local self = setmetatable({}, AbilityTracker)
    self.isActive = false
    self.buffTracker = {}
    self.damageTracker = {}
    self.timer = nil
    return self
end

function AbilityTracker:Reset()
    self.isActive = false
    self.buffTracker = {}
    self.damageTracker = {}
end

function AbilityTracker:RegisterBuff(auraID, name, expirationTime)
    CORE:Log("Added Buff " .. name)
    self.buffTracker[auraID] = Buff.new(name, expirationTime)
end

function AbilityTracker:UnRegisterBuff(auraID)
    if self.buffTracker[auraID] == nil then return end
    CORE:Log("Removed Buff " .. self.buffTracker[auraID].name)
    self.buffTracker[auraID] = nil
end

function AbilityTracker:RegisterDamage(damageSource)
    -- add DamageSource.new()
    -- need to get expire time
end

function AbilityTracker:IsBuffActive(spellName)
    for _, buff in ipairs(self.buffTracker) do
        if buff.name == spellName then return true end
    end
    return false
end

function AbilityTracker:GetData()
    return self.buffTracker, self.damageTracker
end

function AbilityTracker:StartDamageTracker()
    self.timer = C_Timer.NewTicker(1, self.Tick)
end

function AbilityTracker:StopDamageTracker()
    if self.timer:IsCancelled() then return end
    self.timer:Cancel()
end

function AbilityTracker:Tick()

end