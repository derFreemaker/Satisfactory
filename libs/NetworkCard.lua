local Serializer = ModuleLoader.PreLoadModule("Serializer")
local Event = ModuleLoader.PreLoadModule("Event")
local EventPullAdapter = ModuleLoader.PreLoadModule("EventPullAdapter")

--[[
    You can use the addListener method. Will call like this:
    -> "func(signalName, signalSender, data)" <-
]]
local NetworkCard = {}
NetworkCard.__index = NetworkCard

NetworkCard.Events = {}
NetworkCard.networkCard = {}
NetworkCard.logger = {}

function NetworkCard.new(logger, networkCard)
    if networkCard == nil then
        networkCard = computer.getPCIDevices(findClass("NetworkCard"))[1]
        if networkCard == nil then
            error("no networkCard was found")
            return
        end
    end
    event.listen(networkCard)
    local instance = setmetatable({}, NetworkCard)
    instance.logger = logger:create("NetworkCard")
    instance.networkCard = networkCard
    EventPullAdapter:AddListener("NetworkMessage", {Func = instance.networkMessageRecieved, Object = instance}, instance.logger)
    return instance
end

function NetworkCard:networkMessageRecieved(signalName, signalSender, data)
    if data == nil then return end
    local extractedData = {
        SenderIPAddress = data[1],
        Port = data[2],
        EventName = data[3],
        Body = data[4]
    }
    if extractedData.EventName == nil or type(extractedData.EventName) ~= "string" then return end
    for eventName, event in pairs(self.Events) do
        if eventName == extractedData.EventName then
            event:Trigger({
                SignalName = signalName,
                SignalSender = signalSender,
                SenderIPAddress = extractedData.SenderIPAddress,
                Port = extractedData.Port,
                EventName = extractedData.EventName,
                Body = Serializer:Deserialize(extractedData.Body)
            })
        end
    end
end

function NetworkCard:AddListener(onRecivedEventName, listener, logger)
    for eventName, event in pairs(self.Events) do
        if eventName == onRecivedEventName then
            event:AddListener(listener.Func, listener.Object)
            return
        end
    end

    local event = Event.new(onRecivedEventName, logger)
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
    self.networkCard:send(ipAddress, port, eventName, Serializer:Serialize(data))
end
function NetworkCard:BroadCastMessage(port, eventName, data)
    self.networkCard:broadcast(port, eventName, Serializer:Serialize(data))
end

return NetworkCard