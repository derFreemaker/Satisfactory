local Serializer = ModuleLoader.PreLoadModule("Serializer")
local EventPullAdapter = ModuleLoader.PreLoadModule("EventPullAdapter")
local NetworkPort = ModuleLoader.PreLoadModule("NetworkPort")

local NetworkCard = {}
NetworkCard.__index = NetworkCard

function NetworkCard.new(logger, networkCard)
    if networkCard == nil then
        networkCard = computer.getPCIDevices(findClass("NetworkCard"))[1]
        if networkCard == nil then
            error("no networkCard was found")
            return
        end
    end
    local instance = {
        Ports = {},
        networkCard = networkCard,
        logger = logger:create("NetworkCard")
    }
    instance = setmetatable(instance, NetworkCard)
    event.listen(instance.networkCard)
    EventPullAdapter:AddListener("NetworkMessage", {Func = instance.networkMessageRecieved, Object = instance}, instance.logger)
    return instance
end

local function createContext(signalName, signalSender, extractedData)
    return {
        SignalName = signalName,
        SignalSender = signalSender,
        SenderIPAddress = extractedData.SenderIPAddress,
        Port = extractedData.Port,
        EventName = extractedData.EventName,
        Body = Serializer:Deserialize(extractedData.Body),
        Header = Serializer:Deserialize(extractedData.Header)
    }
end

function NetworkCard:networkMessageRecieved(signalName, signalSender, data)
    self.logger:LogTrace("got network message")
    if data == nil then return end
    local extractedData = {
        SenderIPAddress = data[1],
        Port = data[2],
        EventName = data[3],
        Header = data[4],
        Body = data[5]
    }
    if extractedData.EventName == nil or type(extractedData.EventName) ~= "string" then return end
    local removePorts = {}
    for i, port in pairs(self.Ports) do
        if port.Port == data.Port or data.Port == "all" then
            port:executeCallback(createContext(signalName, signalSender, extractedData))
        end
        if #port.Events == 0 then
            table.insert(removePorts, {Pos = i, Port = port})
        end
    end
    for _, port in pairs(removePorts) do
        port.Port:ClosePort()
        table.remove(self.Ports, port.Pos)
    end
end

function NetworkCard:AddListener(onRecivedEventName, onRecivedPort, listener)
    onRecivedPort = (onRecivedPort or "all")

    for _, port in pairs(self.Ports) do
        if port.Port == onRecivedPort then
            port:AddListener(onRecivedEventName, listener)
        end
    end

    local networkClientPort = NetworkPort.new(onRecivedPort, self.logger)
    networkClientPort:AddListener(onRecivedEventName, listener)
    table.insert(self.Ports, networkClientPort)
end

function NetworkCard:AddListenerOnce(onRecivedEventName, onRecivedPort, listener)
    onRecivedPort = (onRecivedPort or "all")

    for _, port in pairs(self.Ports) do
        if port.Port == onRecivedPort then
            port:AddListenerOnce(onRecivedEventName, listener)
        end
    end

    local networkClientPort = NetworkPort.new(onRecivedPort, self.logger)
    networkClientPort:AddListenerOnce(onRecivedEventName, listener)
    table.insert(self.Ports, networkClientPort)
end

function NetworkCard:CreateNetworkPort(port)
    port = (port or "all")

    local netPort = self:GetNetworkPort(port)
    if netPort ~= nil then return netPort end
    netPort = NetworkPort.new(port, self.logger, self)
    table.insert(self.Ports, netPort)
    return netPort
end

function NetworkCard:GetNetworkPort(port)
    for _, networkPort in pairs(self.Ports) do
        if networkPort.Port == port then
            return networkPort
        end
    end
    return nil
end

function NetworkCard:WaitForEvent(eventName, port)
    local gotCalled = false
    local result = nil
    local function set(context)
        gotCalled = true
        result = context
    end
    while gotCalled == false do
        self:AddListenerOnce(eventName, port, {Listener = set, Object = self})
        EventPullAdapter:Wait()
    end
    return result
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
function NetworkCard:SendMessage(ipAddress, port, eventName, data, header)
    self.networkCard:send(ipAddress, port, eventName, Serializer:Serialize(header or {}), Serializer:Serialize(data or {}))
end
function NetworkCard:BroadCastMessage(port, eventName, data)
    self.networkCard:broadcast(port, eventName, Serializer:Serialize(data))
end

return NetworkCard