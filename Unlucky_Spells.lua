--------------------------------------------------------------
--- FUNCTIONS ------------------------------------------------
--------------------------------------------------------------

-- todo remove this
function GetClassData(class)
    if class == "PRIEST" then return Priest end
end

function GetClassSpells(class, spec)
    if class == "Priest" then return Priest:GetSpells(spec) end
    CORE:Error("Class " .. class .. " is not currently supported!")
    return {}
end

--------------------------------------------------------------
--- GLOBAL ---------------------------------------------------
--------------------------------------------------------------

Global = {
    -- potion
    -- healthstone
}

--------------------------------------------------------------
--- Racials --------------------------------------------------
--------------------------------------------------------------

RacialSpells = {
    Dwarf = Spell.new(20594, DamageType.PHYSICAL, bit.bor(SpellType.DISPEL, SpellType.BUFF)), -- Stoneform
    --Draenei = "Gift of the Naaru",
    --DarkIronDwarf = "Fireblood",
    --NightElf = "Shadowmeld",
    --Gnome = "Escape Artist",
    --Human = "Will to Survive",
    --ZandalariTroll = "Regeneratin'"
}

--Spell.new(
--    20594,
--    {
--        SpellAttribute.new(SpellType.DISPEL, bit.bor(DebuffType.POISON, DebuffType.DUSEASE, DebuffType.CURSE, DebuffType.MAGIC, DebuffType.BLEED)),
--        SpellAttribute.new(SpellType.BUFF, DamageType.PHYSICAL)
--    }
--)


--------------------------------------------------------------
--- Priest ---------------------------------------------------
--------------------------------------------------------------

PriestSpec = {
    DISCIPLINE = 1,
    HOLY = 2,
    SHADOW = 4,
    ALL = bit.bor(1,2,4)
}

Priest = PlayerClass.new(PriestSpec)
Priest.Spells["Fade"] = Spell.new(586, DamageType.ALL, SpellType.BUFF, PriestSpec.ALL)
Priest.Spells["Desperate Prayer"] = Spell.new(19236, DamageType.ALL, SpellType.ALL, PriestSpec.ALL)
Priest.Spells["Protective Light"] = Spell.new(193065, DamageType.ALL, SpellType.BUFF, PriestSpec.ALL)
--Priest.Spells["Dispersion"] = Spell.new(586, DamageType.ALL, SpellType.BUFF, PriestSpec.SHADOW)
--Priest.Spells["Vampiric Embrace"] = Spell.new(586, DamageType.ALL, SpellType.BUFF, PriestSpec.SHADOW)