EventListener = {}
EventListener.__index = EventListener

function EventListener.new(onLoadFunc)
    local self = setmetatable({}, EventListener)
    self.events = {}
    self.frame = CreateFrame("Frame", "UnluckyListenerFrame", UIParent)
    self:Init(onLoadFunc)
    return self
end

function EventListener:Init(onLoadFunc)
    if onLoadFunc then
        self:RegisterEvent("ADDON_LOADED", onLoadFunc)
    else
        CORE:Warning("Invalid onLoadFunc!")
    end
    self.frame:SetScript("OnEvent", function(frame, event, ...)
        self:OnEvent(event, ...)
    end)
end

function EventListener:OnEvent(event, ...)
    if self.events[event] then
        self.events[event](event, ...)
    end
end

function EventListener:RegisterEvent(eventName, func)
    if not eventName or not func then
        CORE:Error("Failed to RegisterEvent")
        return
    end
    self.events[eventName] = func
    self.frame:RegisterEvent(eventName)
end

function EventListener:UnregisterEvent(eventName)
    if self.events[eventName] then
        self.frame:UnregisterEvent(eventName)
        self.events = nil
    end
end

function EventListener:UnregisterAllEvents()
    for eventName, _ in pairs(self.events) do
        self:UnregisterEvent(eventName)
    end
end