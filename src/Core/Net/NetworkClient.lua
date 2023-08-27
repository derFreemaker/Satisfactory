local Json = require("Core.Json")
local EventPullAdapter = require("Core.Event.EventPullAdapter")
local Task = require("Core.Task")
local NetworkPort = require("Core.Net.NetworkPort")
local NetworkContext = require("Core.Net.NetworkContext")

---@class Core.Net.NetworkClient : object
---@field Logger Core.Logger
---@field private ports Dictionary<integer | "all", Core.Net.NetworkPort>
---@field private networkCard FicsIt_Networks.Components.FINComputerMod.NetworkCard
---@overload fun(logger: Core.Logger, networkCard: FicsIt_Networks.Components.FINComputerMod.NetworkCard?) : Core.Net.NetworkClient
local NetworkClient = {}

---@private
---@param logger Core.Logger
---@param networkCard FicsIt_Networks.Components.FINComputerMod.NetworkCard?
function NetworkClient:NetworkClient(logger, networkCard)
    if networkCard == nil then
        networkCard = computer.getPCIDevices(findClass("NetworkCard"))[1]
        if networkCard == nil then
            error("no networkCard was found")
        end
    end

    self.Logger = logger
    self.ports = {}
    self.networkCard = networkCard

    event.listen(networkCard)
    EventPullAdapter:AddListener("NetworkMessage", Task(self.networkMessageRecieved, self))
end

---@private
---@param data any[]
function NetworkClient:networkMessageRecieved(data)
    local context = NetworkContext(data)
    self.Logger:LogDebug("recieved network message with event: '" .. context.EventName .. "' on port: '" .. context.Port .. "'")
    for i, port in pairs(self.ports) do
        if port.Port == context.Port or port.Port == "all" then
            port:Execute(context)
        end
        if #port.Events == 0 then
            port:ClosePort()
            self.ports[i] = nil
        end
    end
end

---@protected
---@param port integer | "all"
function NetworkClient:GetNetworkPort(port)
    for portNumber, networkPort in pairs(self.ports) do
        if portNumber == port then
            return networkPort
        end
    end
    return nil
end

---@param onRecivedEventName (string | "all")?
---@param onRecivedPort (integer | "all")?
---@param listener Core.Task
---@return Core.Net.NetworkClient
function NetworkClient:AddListener(onRecivedEventName, onRecivedPort, listener)
    onRecivedEventName = onRecivedEventName or "all"
    onRecivedPort = onRecivedPort or "all"

    local networkPort = self:GetNetworkPort(onRecivedPort) or self:CreateNetworkPort(onRecivedPort)
    networkPort:AddListener(onRecivedEventName, listener)
    return self
end
NetworkClient.On = NetworkClient.AddListener

---@param onRecivedEventName (string | "all")?
---@param onRecivedPort (integer | "all")?
---@param listener Core.Task
---@return Core.Net.NetworkClient
function NetworkClient:AddListenerOnce(onRecivedEventName, onRecivedPort, listener)
    onRecivedEventName = onRecivedEventName or "all"
    onRecivedPort = onRecivedPort or "all"

    local networkPort = self:GetNetworkPort(onRecivedPort) or self:CreateNetworkPort(onRecivedPort)
    networkPort:AddListener(onRecivedEventName, listener)
    return self
end
NetworkClient.Once = NetworkClient.AddListenerOnce

---@param port (integer | "all")?
---@return Core.Net.NetworkPort
function NetworkClient:CreateNetworkPort(port)
    port = port or "all"

    local networkPort = self:GetNetworkPort(port)
    if networkPort ~= nil then
        return networkPort
    end
    networkPort = NetworkPort(port, self.Logger:subLogger("NetworkPort[".. port .."]"), self)
    self.ports[port] = networkPort
    return networkPort
end

---@param eventName string | "all"
---@param port integer | "all"
---@return Core.Net.NetworkContext
function NetworkClient:WaitForEvent(eventName, port)
    self.Logger:LogDebug("waiting for event: '".. eventName .."' on port: ".. port)
    local result
    ---@param context Core.Net.NetworkContext
    local function set(context)
        result = context
    end
    self:AddListenerOnce(eventName, port, Task(set))
    repeat
        EventPullAdapter:Wait()
    until result ~= nil
    return result
end

---@param port integer
function NetworkClient:OpenPort(port)
    self.networkCard:open(port)
end

---@param port integer
function NetworkClient:ClosePort(port)
    self.networkCard:close(port)
end

function NetworkClient:CloseAllPorts()
    self.networkCard:closeAll()
end

---@param ipAddress string
---@param port integer
---@param eventName string
---@param header Dictionary<string, any>?
---@param body any
function NetworkClient:SendMessage(ipAddress, port, eventName, header, body)
    self.networkCard:send(ipAddress, port, eventName, Json.encode(header or {}), Json.encode(body))
end

---@param port integer
---@param eventName string
---@param header Dictionary<string, any>?
---@param body any
function NetworkClient:BroadCastMessage(port, eventName, header, body)
    self.networkCard:broadcast(port, eventName, Json.encode(header or {}), Json.encode(body))
end

return Utils.Class.CreateClass(NetworkClient, "NetworkClient")