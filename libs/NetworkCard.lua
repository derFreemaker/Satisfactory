local Serializer = ModuleLoader.PreLoadModule("Serializer")
local Event = ModuleLoader.PreLoadModule("Event")
local EventPullAdapter = ModuleLoader.PreLoadModule("EventPullAdapter")
local Logger = ModuleLoader.PreLoadModule("Logger")

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
    instance.logger = Logger.new("NetworkCard", debug)
    instance.networkCard = networkCard
    EventPullAdapter:AddListener("NetworkMessage", {Func = instance.onEventPull, Object = instance}, debug)
    return instance
end

NetworkCard.Events = {}
NetworkCard.networkCard = {}
NetworkCard.logger = {}

local function extractMessageData(data)
    return {
        IPAddress = data[1],
        Port = data[2],
        Body = data[3]
    }
end

function NetworkCard:onEventPull(signalName, signalSender, data)
    if data == nil then return end
    data = extractMessageData(data)
    data.Body = Serializer:Deserialize(data.Body)
    if data.EventName == nil then return end
    for eventName, event in pairs(self.Events) do
        if eventName == data.EventName then
            event:Trigger(signalName, signalSender, data)
        end
    end
end

function NetworkCard:AddListener(onRecivedEventName, listener, debug)
    for eventName, event in pairs(self.Events) do
        if eventName == onRecivedEventName then
            event.AddListener(listener.Func, listener.Object)
            return
        end
    end

    local event = Event.new(onRecivedEventName, debug)
    event:AddListener(listener.Func, listener.Object)
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