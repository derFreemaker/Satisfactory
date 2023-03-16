local Serializer = require("Serializer")
local EventPullAdapter = require("EventPullAdapter")
local NetworkPort = require("NetworkPort")

local NetworkClient = {}
NetworkClient.__index = NetworkClient

function NetworkClient.new(logger, networkCard)
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
        _logger = logger:create("NetworkCard")
    }
    instance = setmetatable(instance, NetworkClient)
    event.listen(instance.networkCard)
    EventPullAdapter:AddListener("NetworkMessage", {Func = instance.networkMessageRecieved, Object = instance})
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

function NetworkClient:networkMessageRecieved(signalName, signalSender, data)
    if data == nil then return end
    local extractedData = {
        SenderIPAddress = data[1],
        Port = data[2],
        EventName = data[3],
        Header = data[4],
        Body = data[5]
    }
    self._logger:LogTrace("got network message with event: '"..extractedData.EventName.."'' on port: '"..extractedData.Port.."'")
    if extractedData.EventName == nil then return end
    local removePorts = {}
    for i, port in pairs(self.Ports) do
        if port.Port == extractedData.Port or port.Port == "all" then
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

function NetworkClient:AddListener(onRecivedEventName, onRecivedPort, listener)
    onRecivedPort = (onRecivedPort or "all")

    for _, port in pairs(self.Ports) do
        if port.Port == onRecivedPort then
            port:AddListener(onRecivedEventName, listener)
        end
    end

    local networkPort = NetworkPort.new(onRecivedPort, self._logger)
    networkPort:AddListener(onRecivedEventName, listener)
    table.insert(self.Ports, networkPort)
end

function NetworkClient:AddListenerOnce(onRecivedEventName, onRecivedPort, listener)
    onRecivedPort = (onRecivedPort or "all")

    for _, port in pairs(self.Ports) do
        if port.Port == onRecivedPort then
            port:AddListenerOnce(onRecivedEventName, listener)
        end
    end

    local networkPort = NetworkPort.new(onRecivedPort, self._logger)
    networkPort:AddListenerOnce(onRecivedEventName, listener)
    table.insert(self.Ports, networkPort)
end

function NetworkClient:CreateNetworkPort(port)
    port = (port or "all")

    local networkPort = self:GetNetworkPort(port)
    if networkPort ~= nil then return networkPort end
    networkPort = NetworkPort.new(port, self._logger, self)
    table.insert(self.Ports, networkPort)
    return networkPort
end

function NetworkClient:GetNetworkPort(port)
    for _, networkPort in pairs(self.Ports) do
        if networkPort.Port == port then
            return networkPort
        end
    end
    return nil
end

function NetworkClient:WaitForEvent(eventName, port)
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

function NetworkClient:OpenPort(port)
    self.networkCard:open(port)
end
function NetworkClient:ClosePort(port)
    self.networkCard:close(port)
end
function NetworkClient:CloseAllPorts()
    self.networkCard:closeAll()
end
function NetworkClient:SendMessage(ipAddress, port, eventName, data, header)
    self.networkCard:send(ipAddress, port, eventName, Serializer:Serialize(header or {}), Serializer:Serialize(data or {}))
end
function NetworkClient:BroadCastMessage(port, eventName, data)
    self.networkCard:broadcast(port, eventName, Serializer:Serialize(data))
end

return NetworkClient