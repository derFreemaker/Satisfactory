local Serializer = ModuleLoader.PreLoadModule("Serializer")
local Event = ModuleLoader.PreLoadModule("Event")
local EventPullAdapter = ModuleLoader.PreLoadModule("EventPullAdapter")

--[[
    You can use the addListener method. Will call like this:
    -> "func(signalName, signalSender, data)" <-
]]
local NetworkCard = {}
NetworkCard.__index = NetworkCard

function NetworkCard.new(debug, networkCard)
    if networkCard == nil then
        networkCard = computer.getPCIDevices(findClass("NetworkCard"))[1]
        if networkCard == nil then
            error("no networkCard was found")
            return
        end
    end
    event.listen(networkCard)
    local instance = setmetatable({}, NetworkCard)
    instance.networkCard = networkCard
    EventPullAdapter:AddListener("NetworkMessage", instance.onEventPull, debug)
    return instance
end

NetworkCard.Events = {}
NetworkCard.networkCard = {}

function NetworkCard:onEventPull(signalName, signalSender, data)
    if data == nil then return end
    data = Serializer:Deserialize(data)
    if data.EventName == nil then return end
    for eventName, event in pairs(self.Events) do
        if eventName == data.EventName then
            event:Trigger(signalName, signalSender, data)
        end
    end
end

function NetworkCard:AddListener(onRecivedEventName, func, debug)
    for eventName, event in pairs(self.Events) do
        if eventName == onRecivedEventName then
            event.AddListener(func)
            return
        end
    end

    local event = Event.new(onRecivedEventName, debug)
    event:AddListener(func)
    self.Events[onRecivedEventName] = event
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
function NetworkCard:SendMessage(ipAddress, port, eventName, data)
    self.networkCard:send(ipAddress, port, eventName, data)
end
function NetworkCard:BroadCastMessage(port, eventName, data)
    self.networkCard:broadcast(port, eventName, data)
end

return NetworkCard