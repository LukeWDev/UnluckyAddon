if not UnluckyDB then
    UnluckyDB = {
        enableDebugLog = true,
        damageExpireTimeSeconds = 5
    }
end

CORE = {}
local logColour = {
    RED = "|cffff0000",
    YELLOW = "|cffffff00",
    RESET = "|r"
}

function CORE:Log(message)
    print("Unlucky: " .. message)
end

function CORE:Warning(message)
    print(logColour.YELLOW .. "Unlucky Warning: " .. message .. logColour.RESET)
end

function CORE:Error(message)
    print(logColour.RED .. "Unlucky Error: " .. message .. logColour.RESET)
end

function CORE:GetCurrentTime()
    return GetServerTime() + (GetTime() % 1)
end