local PackageData = {}

-- ########## Net.Core ##########

PackageData.MFYoiWSx = {
    Namespace = "Net.Core.NetworkClient",
    Name = "NetworkClient",
    FullName = "NetworkClient.lua",
    IsRunnable = true,
    Data = [[
local Json = require("Core.Json")
local EventPullAdapter = require("Core.Event.EventPullAdapter")
local Task = require("Core.Task")
local NetworkPort = require("Net.Core.NetworkPort")
local NetworkContext = require("Net.Core.NetworkContext")

---@class Core.Net.NetworkClient : object
---@field private id string?
---@field private Logger Core.Logger
---@field private ports Dictionary<integer | "all", Core.Net.NetworkPort>
---@field private networkCard FicsIt_Networks.Components.FINComputerMod.NetworkCard
---@overload fun(logger: Core.Logger, networkCard: FicsIt_Networks.Components.FINComputerMod.NetworkCard?) : Core.Net.NetworkClient
local NetworkClient = {}

---@private
---@param logger Core.Logger
---@param networkCard FicsIt_Networks.Components.FINComputerMod.NetworkCard?
function NetworkClient:__init(logger, networkCard)
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

---@return string
function NetworkClient:GetId()
    if self.id then
        return self.id
    end

    local splittedPrint = Utils.String.Split(tostring(self.networkCard), " ")
    self.id = splittedPrint[#splittedPrint]
    return self.id
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
        if Utils.Table.Count(port:GetEvents()) == 0 then
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
---@return Core.Net.NetworkPort
function NetworkClient:AddListener(onRecivedEventName, onRecivedPort, listener)
    onRecivedEventName = onRecivedEventName or "all"
    onRecivedPort = onRecivedPort or "all"

    local networkPort = self:GetNetworkPort(onRecivedPort) or self:CreateNetworkPort(onRecivedPort)
    networkPort:AddListener(onRecivedEventName, listener)
    return networkPort
end
NetworkClient.On = NetworkClient.AddListener

---@param onRecivedEventName (string | "all")?
---@param onRecivedPort (integer | "all")?
---@param listener Core.Task
---@return Core.Net.NetworkPort
function NetworkClient:AddListenerOnce(onRecivedEventName, onRecivedPort, listener)
    onRecivedEventName = onRecivedEventName or "all"
    onRecivedPort = onRecivedPort or "all"

    local networkPort = self:GetNetworkPort(onRecivedPort) or self:CreateNetworkPort(onRecivedPort)
    networkPort:AddListener(onRecivedEventName, listener)
    return networkPort
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
---@param timeout number?
---@return Core.Net.NetworkContext?
function NetworkClient:WaitForEvent(eventName, port, timeout)
    self.Logger:LogDebug("waiting for event: '".. eventName .."' on port: ".. port)
    local result
    ---@param context Core.Net.NetworkContext
    local function set(context)
        result = context
    end
    self:AddListenerOnce(eventName, port, Task(set)):OpenPort()
    repeat
        if not EventPullAdapter:Wait(timeout) then
            break
        end
    until result ~= nil
    return result
end

---@param port integer
function NetworkClient:OpenPort(port)
    self.networkCard:open(port)
    self.Logger:LogTrace("opened Port: " .. port)
end

---@param port integer
function NetworkClient:ClosePort(port)
    self.networkCard:close(port)
    self.Logger:LogTrace("closed Port: " .. port)
end

function NetworkClient:CloseAllPorts()
    self.networkCard:closeAll()
    self.Logger:LogTrace("closed all Ports")
end

---@param ipAddress string
---@param port integer
---@param eventName string
---@param body any
---@param header Dictionary<string, any>?
function NetworkClient:SendMessage(ipAddress, port, eventName, body, header)
    self.networkCard:send(ipAddress, port, eventName, Json.encode(body), Json.encode(header or {}))
end

---@param port integer
---@param eventName string
---@param body any
---@param header Dictionary<string, any>?
function NetworkClient:BroadCastMessage(port, eventName, body, header)
    self.networkCard:broadcast(port, eventName, Json.encode(body), Json.encode(header or {}))
end

return Utils.Class.CreateClass(NetworkClient, "Core.Net.NetworkClient")
]]
}

PackageData.oVIzFPpX = {
    Namespace = "Net.Core.NetworkContext",
    Name = "NetworkContext",
    FullName = "NetworkContext.lua",
    IsRunnable = true,
    Data = [[
local Json = require("Core.Json")
local RestApiRequest = require("Net.Rest.RestApii.RestApiRequest")
local RestApiResponse = require("Net.Rest.RestApii.RestApiResponse")

---@class Core.Net.NetworkContext : object
---@field SignalName string
---@field SignalSender FicsIt_Networks.Components.Object
---@field SenderIPAddress string
---@field Port integer
---@field EventName string
---@field Header Dictionary<string, any>
---@field Body any
---@overload fun(data: any[]) : Core.Net.NetworkContext
local NetworkContext = {}

---@private
---@param data any[]
function NetworkContext:__init(data)
    self.SignalName = data[1]
    self.SignalSender = data[2]
    self.SenderIPAddress = data[3]
    self.Port = data[4]
    self.EventName = data[5]
    self.Header = Json.decode(data[7] or "null")
    self.Body = Json.decode(data[6] or "null")
end

---@return Core.RestApi.RestApiRequest
function NetworkContext:ToApiRequest()
    return RestApiRequest(self.Body.Method, self.Body.Endpoint, self.Body.Body, self.Body.Headers)
end

---@return Core.RestApi.RestApiResponse
function NetworkContext:ToApiResponse()
    return RestApiResponse(self.Body.Body, self.Body.Headers)
end

return Utils.Class.CreateClass(NetworkContext, "Core.Net.NetworkContext")
]]
}

PackageData.PksKdJNx = {
    Namespace = "Net.Core.NetworkPort",
    Name = "NetworkPort",
    FullName = "NetworkPort.lua",
    IsRunnable = true,
    Data = [[
local Event = require("Core.Event.Event")

---@class Core.Net.NetworkPort : object
---@field Port integer | "all"
---@field private events Dictionary<string, Core.Event>
---@field private netClient Core.Net.NetworkClient
---@field private logger Core.Logger
---@overload fun(port: integer | "all", logger: Core.Logger, netClient: Core.Net.NetworkClient) : Core.Net.NetworkPort
local NetworkPort = {}

---@private
---@param port integer | "all"
---@param logger Core.Logger
---@param netClient Core.Net.NetworkClient
function NetworkPort:__init(port, logger, netClient)
    self.Port = port
    self.events = {}
    self.logger = logger
    self.netClient = netClient
end

---@return Dictionary<string, Core.Event>
function NetworkPort:GetEvents()
    return Utils.Table.Copy(self.events)
end

---@return Core.Net.NetworkClient
function NetworkPort:GetNetClient()
    return self.netClient
end

---@param context Core.Net.NetworkContext
function NetworkPort:Execute(context)
    self.logger:LogTrace("got triggered with event: '".. context.EventName .."'")
    for name, event in pairs(self.events) do
        if name == context.EventName or name == "all" then
            event:Trigger(self.logger, context)
        end
        if #event == 0 then
            self.events[name] = nil
        end
    end
end

---@protected
---@param eventName string | "all"
---@return Core.Event
function NetworkPort:GetEvent(eventName)
    for name, event in pairs(self.events) do
        if name == eventName then
            return event
        end
    end
    local event = Event()
    self.events[eventName] = event
    return event
end

---@param onRecivedEventName string | "all"
---@param listener Core.Task
---@return Core.Net.NetworkPort
function NetworkPort:AddListener(onRecivedEventName, listener)
    local event = self:GetEvent(onRecivedEventName)
    event:AddListener(listener)
    return self
end
NetworkPort.On = NetworkPort.AddListener

---@param onRecivedEventName string | "all"
---@param listener Core.Task
---@return Core.Net.NetworkPort
function NetworkPort:AddListenerOnce(onRecivedEventName, listener)
    local event = self:GetEvent(onRecivedEventName)
    event:AddListenerOnce(listener)
    return self
end
NetworkPort.Once = NetworkPort.AddListenerOnce

---@param eventName string
---@param timeout number?
---@return Core.Net.NetworkContext?
function NetworkPort:WaitForEvent(eventName, timeout)
    return self.netClient:WaitForEvent(eventName, self.Port, timeout)
end

function NetworkPort:OpenPort()
    local port = self.Port
    if type(port) == "number" then
        self.netClient:OpenPort(port)
    end
end

function NetworkPort:ClosePort()
    local port = self.Port
    if type(port) == "number" then
        self.netClient:ClosePort(port)
    end
end

---@param ipAddress string
---@param eventName string
---@param body any
---@param header Dictionary<string, any>?
function NetworkPort:SendMessage(ipAddress, eventName, body, header)
    local port = self.Port
    if port == "all" then
        error("Unable to send a message over all ports")
    end
    ---@cast port integer
    self.netClient:SendMessage(ipAddress, port, eventName, body, header)
end

---@param eventName string
---@param body any
---@param header Dictionary<string, any>?
function NetworkPort:BroadCastMessage(eventName, body, header)
    local port = self.Port
    if port == "all" then
        error("Unable to broadcast a message over all ports")
    end
    ---@cast port integer
    self.netClient:BroadCastMessage(port, eventName, body, header)
end

return Utils.Class.CreateClass(NetworkPort, "Core.Net.NetworkPort")
]]
}

-- ########## Net.Core ########## --

return PackageData
