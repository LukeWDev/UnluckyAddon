AttackType = {
    NONE = 0,
    MELEE = 1,
    RANGED_ATTACK = 2,
    SPELL = 4,
    DOT = 8,
    ENVIRONMENT = 16
}

DamageType = {
    PHYSICAL = 1,
    MAGIC = 2,
    NATURE = 4,
    SHADOW = 8,
    HOLY = 16,
    FIRE = 32,
    FROST = 64,
    ARCANE = 128,
    CHAOS = 256,
    PIERCING = 512,
    ALL = bit.bor(1,2,4,8,16,32,64,128,256,512)
}

DebuffType = {
    CURSE = 1,
    DISEASE = 2,
    MAGIC = 4,
    POISON = 8,
    PHYSICAL = 16,
    SHADOW = 32,
    SILENCE = 64,
    SLOW = 128,
    STUN = 256,
    WEAKEN = 512,
    ALL = bit.bor(1,2,4,8,16,32,64,128,256,512)
}

--------------------------------------------------------------
--- The source of a recent attack result on the player
DamageSource = {}
DamageSource.__index = DamageSource

function DamageSource.new(damageType)
    local self = setmetatable({}, DamageSource)
    self.damageType = damageType
    return self
end

--------------------------------------------------------------
--- Data container which holds data on which class spells to track 
PlayerClass = {}
PlayerClass.__index = PlayerClass

function PlayerClass.new(specClass)
    local self = setmetatable({}, PlayerClass)
    self.specClass = specClass
    self.Spells = {}
    return self
end

function PlayerClass:GetSpells(spec)
    local outSpells = {}
    if not spec then return outSpells end
    for spellName, spellClass in pairs(self.Spells) do
        if spellClass:IsValidForActiveTalents(self.specClass[string.upper(spec)]) then
            print(spellName)
            outSpells[spellName] = spellClass
        end
    end
    return outSpells
end

--------------------------------------------------------------
--- Data container which holds data related to a specific spell
Spell = {}
Spell.__index = Spell

SpellType = {
    BUFF = 1,
    HEAL = 2,
    DISPEL = 4,
    ALL = bit.bor(1,2,4)
}

function Spell.new(spell, damageType, spellType, spec, requiredTalentNodeID)
    local self = setmetatable({}, Spell)
    self.spellID = spell
    local spellInfo = C_Spell.GetSpellInfo(self.spellID)
    self.spellName = spellInfo.name
    self.damageType = damageType
    self.spellType = spellType
    self.spec = spec
    if not requiredTalentNodeID then
        self.requiredTalentNodeID = nil
    else
        self.requiredTalentNodeID = requiredTalentNodeID
    end
    return self
end

function Spell:IsOnCooldown()
    if not IsPlayerSpell(self.spellID) then return false end
    local spellCooldownInfo = C_Spell.GetSpellCooldown(self.spellID)
    return spellCooldownInfo.startTime ~= 0
end

function Spell:IsActive(activeBuffs)
    for _, buff in pairs(activeBuffs) do
        if buff.name == self.spellName then
            return true
        end
    end
    return false
end

function Spell:GetSpellID()
    return self.spellID
end

function Spell:GetSpellName()
    return self.spellName
end

function Spell:GetDamageType()
    return self.damageType
end

function Spell:GetSpellType()
    return self.spellType
end

function Spell:Get()
    return self.spellID, self.damageType, self.spellType, self.spec, self.requiredTalentNodeID
end

function Spell:IsMatchingDamageType(type)
    return bit.band(type, self.damageType) > 0
end

local function IsTalentSelected(spellName, nodeID)
    local configID = C_ClassTalents.GetActiveConfigID()
    if configID == nil then return end
    local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
    for _, entryID in ipairs(nodeInfo.entryIDsWithCommittedRanks) do
        local entryInfo = C_Traits.GetEntryInfo(configID, entryID)
        local def = C_Traits.GetDefinitionInfo(entryInfo.definitionID)
        local spellInfo = C_Spell.GetSpellInfo(def.spellID)
        if spellInfo.name == spellName then
            return true
        end
    end
    return false
end

function Spell:IsValidForActiveTalents(spec)
    local isSpellValidForSpec = bit.band(self.spec, spec) > 0
    if not self.requiredTalentNodeID then
        return isSpellValidForSpec
    end
    return isSpellValidForSpec and IsTalentSelected(self.spellName, self.requiredTalentNodeID)
end

--------------------------------------------------------------
--- Data container which holds data related to a specific spell attribue
SpellAttribute = {}
SpellAttribute.__index = SpellAttribute

function SpellAttribute.new(spellType, attributeType)
    local self = setmetatable({}, SpellAttribute)
    self.spellType = spellType
    self.attributeType = attributeType
    return self
end