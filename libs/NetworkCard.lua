local Event = ModuleLoader.PreLoadModule("Event")
local EventPullAdapter = ModuleLoader.PreLoadModule("EventPullAdapter")
local Serializer = ModuleLoader.PreLoadModule("Serializer")

--[[
    You can use the addListener method. Will call like this:
    -> "func(signalName, signalSender, data)" <-
]]
local NetworkCard = {}
NetworkCard.__index = NetworkCard

function NetworkCard.new(networkCard)
    if networkCard == nil then
        networkCard = computer.getPCIDevices(findClass("NetworkCard"))[1]
        if networkCard == nil then
            error("no networkCard was found")
        end
    end
    local instance = setmetatable({}, NetworkCard)
    instance.networkCard = networkCard
    event.listen(networkCard)
    EventPullAdapter:addListener("NetworkMessage", instance.onEventPull)
    return instance
end

NetworkCard.Events = {}
NetworkCard.networkCard = {}

function NetworkCard:onEventPull(signalName, signalSender, data)
    data = Serializer:Deserialize(data)
    if data.EventName == nil then return end
    for eventName, event in pairs(self.Events) do
        if eventName == data.EventName then
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

function NetworkCard:SendMessage(ipAddress, port, data)
    self.networkCard:send(ipAddress, port, data)
end
function NetworkCard:OpenPort(port)
    self.networkCard:open(port)
end
function NetworkCard:ClosePort(port)
    self.networkCard:close(port)
end
function NetworkCard:CloseAllPorts()
    self.networkCard:closeAll()
end
function NetworkCard:BroadCastMessage(port, data)
    self.networkCard:broadcast(port, data)
end

return NetworkCard