---
--- Created by Freemaker
--- DateTime: 15/01/2023
---

local Event = filesystem.doFile("Event.lua")
--[[
    If you use NetworkCard client you can not use any other event pull

    You can use the addListener will call like this.
    -> "func(eventName, signalSender, optionalParameters)"" <-
]]
NetworkCard = {}
NetworkCard.__index = NetworkCard

function NetworkCard.new()
    local instance = setmetatable({}, NetworkCard)
    instance.OnEventPull = Event.new()
    return instance
end

NetworkCard.OnEventPull = {}

function NetworkCard:Wait()
    local eventPull = {event.pull()}
    local eventName, signalSender, optionalParameters = (function(eventName, signalSender, ...)
        return eventName, signalSender, {...}
    end)(table.unpack(eventPull))
    self.OnEventPull:trigger(eventName, signalSender, optionalParameters)
end

function NetworkCard:Run()
    while true do
        self:Wait()
    end
end

return NetworkCard