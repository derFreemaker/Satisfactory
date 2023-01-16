---
--- Created by Freemaker
--- LastChange: 16/01/2023
---

local Event = filesystem.doFile("Event.lua")
--[[
    If you use NetworkCard client you can not use any other event pull.
    And you can only use this to send data properly. 

    You can use the addListener under [object].OnEventPull will call like this.
    -> "func(signalName, signalSender, recivedEventName, data)" <-

    Or you can add add listner directly with the an event name so its only called when the event name was recieved.
    Will call like this.
    -> "func(signalName, signalSender, data)"
]]
local NetworkCard = {}
NetworkCard.__index = NetworkCard

function NetworkCard.new()
    local instance = setmetatable({}, NetworkCard)
    instance.OnEventPull = Event.new()
    instance.OnEventPull.addListener(instance.onEventPull)
    return instance
end

NetworkCard.OnEventPull = {}
NetworkCard.Events = {}

function NetworkCard:onEventPull(signalName, signalSender, recivedEventName, data)
    for eventName, event in pairs(self.Events) do
        if eventName == recivedEventName then
            event:trigger(signalName, signalSender, data)
        end
    end
end

function NetworkCard:AddListener(onRecivedEventName, func)
    for eventName, event in pairs(self.Events) do
        if eventName == onRecivedEventName then
            event.addListener(func)
            return
        end
    end

    local event = Event.new()
    event.addListener(func)
    self.Events[onRecivedEventName] = event
end

function NetworkCard:Wait()
    local eventPull = {event.pull()}
    local signalName, signalSender, recivedEventName, data = (function(signalName, signalSender, recivedEventName, ...)
        return signalName, signalSender, recivedEventName, {...}
    end)(table.unpack(eventPull))

    self.Events.OnEventPull:trigger(signalName, signalSender, recivedEventName, data)
end

function NetworkCard:Run()
    while true do
        self:Wait()
    end
end

return NetworkCard