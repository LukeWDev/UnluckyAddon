local Content = {
    DUNGEON = 1,
    RAID = 2,
    ALL = bit.bor(1,2)
}

local Role = {
    TANK = 1,
    HEALER = 2,
    DPS = 4,
    ALL = bit.bor(1, 2, 4)
}

local Excuse = {}
Excuse.__index = Excuse

function Excuse.new(text, contentFlags, roleFlags)
    local self = setmetatable({}, Excuse)
    self.Text = text
    self.ContentFlags = contentFlags
    self.RoleFlags = roleFlags
    return self
end

ExcuseGenerator = {}
ExcuseGenerator.__index = ExcuseGenerator

function ExcuseGenerator.new()
    local self = setmetatable({}, ExcuseGenerator)
    self.Excuses = {
        Excuse.new("I just had a massive lag spike", Content.ALL, Role.ALL),
        Excuse.new("My mouse just ran out of battery", Content.ALL, Role.ALL),
        Excuse.new("My keyboard ran out of battery", Content.ALL, Role.ALL),
        Excuse.new("My cat just walked in front of my monitor", Content.ALL, Role.ALL),
        Excuse.new("My dog was turning the rug into a bed", Content.ALL, Role.ALL),
        Excuse.new("Someone knocked on my door", Content.ALL, Role.ALL),
        Excuse.new("I did so much damage that I pulled aggro", Content.ALL, Role.ALL),
        Excuse.new("This tank route is so weird and bad", Content.DUNGEON, bit.band(Role.DPS, Role.HEALER)),
        Excuse.new("My FPS on this fight is awful", Content.DUNGEON, bit.band(Role.DPS, Role.HEALER)),
        Excuse.new("This tank route is so weird and bad", Content.DUNGEON, bit.band(Role.DPS, Role.HEALER)),
    }
    self:Reset()
end

function ExcuseGenerator:Reset()
    self.ExcusePool = self.Excuses
end

function ExcuseGenerator:GenerateExcuse()
    -- keep track of used excuses or just use a random seed?
    local inInstance, instanceType = IsInInstance()
    local currentContent
    if instanceType == "party" then currentContent = Content.DUNGEON
    elseif instanceType == "raid" then currentContent = Content.RAID
    else currentContent = Content.ALL end
        
    local currentRole = Role.ALL -- TODO GET THIS
    local possibleExcuses = {}
    for _, excuse in ipairs(self.ExcusePool) do
        if bit.band(excuse.ContentFlags, currentContent) > 0 and bit.band(excuse.RoleFlags, currentRole) > 0 then
            table.insert(possibleExcuses, excuse)
        end
    end
    local index = math.random(#possibleExcuses)
    local selectedExcuse = self.ExcusePool[index]
    table.remove(self.ExcusePool, index)
    return selectedExcuse
end

local function GetInstanceType()
    -- 
end

local function GetRoleType()
    -- UnitGroupRolesAssigned
end