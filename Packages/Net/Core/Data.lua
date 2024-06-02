local Data={
["Net.Core.__events"] = [==========[
local JsonSerializer = require("Core.Json.JsonSerializer")

---@class Net.Core.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    JsonSerializer.Static__Serializer:AddClasses({
        -- IPAddress
        require("Net.Core.IPAddress"),
    })

    -- Loading Host Extensions
    require("Net.Core.Hosting.HostExtensions")
end

return Events

]==========],
["Net.Core.IPAddress"] = [==========[
---@class Net.Core.IPAddress : object, Core.Json.ISerializable
---@field private m_address FIN.UUID
---@overload fun(address: string) : Net.Core.IPAddress
local IPAddress = {}

---@private
---@param address FIN.UUID
function IPAddress:__init(address)
    self:Raw__ModifyBehavior(function (modify)
        modify.CustomIndexing = false
    end)

    self.m_address = address

    self:Raw__ModifyBehavior(function (modify)
        modify.CustomIndexing = true
    end)
end

---@return FIN.UUID
function IPAddress:GetAddress()
    return self.m_address
end

---@param ipAddress Net.Core.IPAddress
function IPAddress:Equals(ipAddress)
    return self:GetAddress() == ipAddress:GetAddress()
end

---@private
function IPAddress:__newindex()
    error("Net.Core.IPAddress is read only.")
end

---@private
function IPAddress:__tostring()
    return self:GetAddress()
end

--#region - Serializable -

---@return string address
function IPAddress:Serialize()
    return self.m_address
end

--#endregion

return class("Net.Core.IPAddress", IPAddress,
    { Inherit = require("Core.Json.ISerializable") })

]==========],
["Net.Core.Method"] = [==========[
---@enum Net.Core.Method
local Methods = {
	GET = "GET",
	HEAD = "HEAD",
	POST = "POST",
	PUT = "PUT",
	CREATE = "CREATE",
	DELETE = "DELETE",
	CONNECT = "CONNECT",
	OPTIONS = "OPTIONS",
	TRACE = "TRACE",
	PATCH = "PATCH"
}

return Methods

]==========],
["Net.Core.NetworkClient"] = [==========[
local NetworkCardAdapter = require("Adapter.Computer.NetworkCard")
local JsonSerializer = require("Core.Json.JsonSerializer")
local EventPullAdapter = require("Core.Event.EventPullAdapter")
local Task = require("Core.Common.Task")
local NetworkPort = require("Net.Core.NetworkPort")
local NetworkContext = require("Net.Core.NetworkContext")
local NetworkFuture = require("Net.Core.NetworkFuture")

local IPAddress = require("Net.Core.IPAddress")

---@alias Net.Core.Port
---|integer
---|"*"

---@alias Net.Core.EventName
---|string
---|"*"

---@class Net.Core.NetworkClient : object
---@field private m_iPAddress Net.Core.IPAddress
---@field private m_ports table<Net.Core.Port, Net.Core.NetworkPort?>
---@field private m_networkCard Adapter.Computer.NetworkCard
---@field private m_serializer Core.Json.Serializer
---@field private m_logger Core.Logger
---@field private m_onNetworkMessageReceivedTaskIndex integer
---@overload fun(logger: Core.Logger, networkCard: Adapter.Computer.NetworkCard?, serializer: Core.Json.Serializer?) : Net.Core.NetworkClient
local NetworkClient = {}

---@private
---@param logger Core.Logger
---@param networkCard Adapter.Computer.NetworkCard?
---@param serializer Core.Json.Serializer?
function NetworkClient:__init(logger, networkCard, serializer)
	self.m_logger = logger
	self.m_ports = {}
	self.m_networkCard = networkCard or NetworkCardAdapter(1)

	self.m_serializer = serializer or JsonSerializer.Static__Serializer

	self.m_networkCard:Listen()
	self.m_onNetworkMessageReceivedTaskIndex = EventPullAdapter:AddTask(
		"NetworkMessage",
		Task(function(data)
			self:networkMessageReceived(data)
		end)
	)
end

---@private
function NetworkClient:__gc()
	self.m_ports = nil
	EventPullAdapter:Remove("NetworkMessage", self.m_onNetworkMessageReceivedTaskIndex)
end

function NetworkClient:Dispose()
	Utils.Class.Deconstruct(self)
end

---@return Net.Core.IPAddress
function NetworkClient:GetIPAddress()
	if self.m_iPAddress then
		return self.m_iPAddress
	end

	self.m_iPAddress = IPAddress(self.m_networkCard:GetIPAddress())
	return self.m_iPAddress
end

---@return string nick
function NetworkClient:GetNick()
	return self.m_networkCard:GetNick()
end

---@return Core.Json.Serializer serializer
function NetworkClient:GetJsonSerializer()
	return self.m_serializer
end

---@param port Net.Core.Port
---@return Net.Core.NetworkPort?
function NetworkClient:GetNetworkPort(port)
	return self.m_ports[port]
end

---@param port (Net.Core.Port)?
---@return Net.Core.NetworkPort
function NetworkClient:GetOrCreateNetworkPort(port)
	port = port or "*"

	local networkPort = self:GetNetworkPort(port)
	if networkPort then
		return networkPort
	end

	networkPort = NetworkPort(port, self.m_logger:subLogger('NetworkPort[' .. port .. ']'), self)
	self.m_ports[port] = networkPort
	return networkPort
end

---@param port Net.Core.Port | Net.Core.NetworkPort?
function NetworkClient:RemoveNetworkPort(port)
	if port == "*" or type(port) == "number" then
		port = self:GetNetworkPort(port)
	end
	---@cast port Net.Core.NetworkPort?

	if not port then
		return
	end

	port:ClosePort()
	self.m_ports[port.Port] = nil
	Utils.Class.Deconstruct(port)
end

---@private
---@param port Net.Core.Port
---@param context Net.Core.NetworkContext
---@return boolean foundPort
function NetworkClient:executeNetworkPort(port, context)
	local netPort = self:GetNetworkPort(port)
	if not netPort then
		return false
	end

	netPort:Execute(context)
	if netPort:GetEventsCount() == 0 then
		self:RemoveNetworkPort(netPort)
	end
	return true
end

---@private
---@param data any[]
function NetworkClient:networkMessageReceived(data)
	local context = NetworkContext(data, self.m_serializer)
	self.m_logger:LogDebug("received network message with event: '" ..
		context.EventName .. "' on port: " .. context.Port)


	local foundPort = self:executeNetworkPort(context.Port, context)
	if not foundPort then
		self:Close(context.Port)
	end

	self:executeNetworkPort("*", context)
end

---@param onReceivedEventName Net.Core.EventName?
---@param onReceivedPort Net.Core.Port?
---@param listener Core.Task
---@return Net.Core.NetworkPort, number taskIndex
function NetworkClient:AddTask(onReceivedEventName, onReceivedPort, listener)
	onReceivedEventName = onReceivedEventName or "*"
	onReceivedPort = onReceivedPort or "*"

	local networkPort = self:GetOrCreateNetworkPort(onReceivedPort)
	return networkPort, networkPort:AddTask(onReceivedEventName, listener)
end

---@param onReceivedEventName Net.Core.EventName
---@param onReceivedPort Net.Core.Port
---@param listener Core.Task
---@return Net.Core.NetworkPort, number taskIndex
function NetworkClient:AddTaskOnce(onReceivedEventName, onReceivedPort, listener)
	onReceivedEventName = onReceivedEventName or '*'
	onReceivedPort = onReceivedPort or "*"

	local networkPort = self:GetOrCreateNetworkPort(onReceivedPort)
	return networkPort, networkPort:AddTaskOnce(onReceivedEventName, listener)
end

---@async
---@param eventName Net.Core.EventName
---@param port Net.Core.Port
---@param timeoutSeconds number?
---@return Net.Core.NetworkContext?
function NetworkClient:WaitForEvent(eventName, port, timeoutSeconds)
	local result

	---@param context Net.Core.NetworkContext
	local netPort = self:AddTaskOnce(eventName, port, Task(function(context)
		result = context
	end))
	netPort:OpenPort()

	self.m_logger:LogDebug("waiting for event: '" .. eventName .. "' on port: " .. port)
	while result == nil do
		if not EventPullAdapter:Wait(timeoutSeconds) then
			break
		end
	end

	return result
end

---@param eventName string
---@param port Net.Core.Port
---@param timeoutSeconds number?
function NetworkClient:CreateEventFuture(eventName, port, timeoutSeconds)
	return NetworkFuture(self, eventName, port, timeoutSeconds)
end

---@param port integer
function NetworkClient:Open(port)
	if self.m_networkCard:OpenPort(port) then
		self.m_logger:LogTrace('opened Port: ' .. port)
	end
end

---@param port integer
function NetworkClient:Close(port)
	self.m_networkCard:ClosePort(port)
	self.m_logger:LogTrace('closed Port: ' .. port)
end

function NetworkClient:CloseAll()
	self.m_networkCard:CloseAllPorts()
	self.m_logger:LogTrace('closed all Ports')
end

---@param ipAddress Net.Core.IPAddress
---@param port integer
---@param eventName string
---@param body any
---@param headers table<string, any>?
function NetworkClient:Send(ipAddress, port, eventName, body, headers)
	local jsonBody = self.m_serializer:Serialize(body)
	local jsonHeader = self.m_serializer:Serialize(headers)

	self.m_logger:LogTrace(
		"sending to '" .. ipAddress:GetAddress()
		.. "' on port: " .. port
		.. " with event: '" .. eventName .. "'")

	self.m_networkCard:Send(ipAddress:GetAddress(), port, eventName, jsonBody, jsonHeader)
end

---@param port integer
---@param eventName string
---@param body any
---@param header table<string, any>?
function NetworkClient:BroadCast(port, eventName, body, header)
	local jsonBody = self.m_serializer:Serialize(body)
	local jsonHeader = self.m_serializer:Serialize(header)

	self.m_logger:LogTrace("broadcast on port: " .. port .. " with event: '" .. eventName .. "'")

	self.m_networkCard:BroadCast(port, eventName, jsonBody, jsonHeader)
end

return class("Core.Net.NetworkClient", NetworkClient)

]==========],
["Net.Core.NetworkContext"] = [==========[
local JsonSerializer = require("Core.Json.JsonSerializer")
local IPaddress = require("Net.Core.IPAddress")

---@class Net.Core.NetworkContext.Header : table<string, any>
---@field ReturnIPAddress Net.Core.IPAddress
---@field ReturnPort integer

---@class Net.Core.NetworkContext : object
---@field SignalName string
---@field SignalSender Engine.Object
---@field SenderIPAddress Net.Core.IPAddress
---@field Port integer
---@field EventName string
---@field Header Net.Core.NetworkContext.Header
---@field Body any
---@overload fun(data: any[], serializer: Core.Json.Serializer?) : Net.Core.NetworkContext
local NetworkContext = {}

---@private
---@param data any[]
---@param serializer Core.Json.Serializer?
function NetworkContext:__init(data, serializer)
	if not serializer then
		serializer = JsonSerializer.Static__Serializer
	end

	self.SignalName = data[1]
	self.SignalSender = data[2]
	self.SenderIPAddress = IPaddress(data[3])
	self.Port = data[4]
	self.EventName = data[5]
	self.Body = serializer:Deserialize(data[6] or "null")
	self.Header = serializer:Deserialize(data[7] or "null") or {}

	if not self.Header.ReturnIPAddress then
		self.Header.ReturnIPAddress = self.SenderIPAddress
	end
end

return class("Core.Net.NetworkContext", NetworkContext)

]==========],
["Net.Core.NetworkFuture"] = [==========[
---@class Net.Core.NetworkFuture : object
---@field private m_eventName string
---@field private m_port Net.Core.Port
---@field private m_timeoutSeconds number?
---@field private m_networkClient Net.Core.NetworkClient
---@overload fun(networkClient: Net.Core.NetworkClient, eventName: string, port: Net.Core.Port, timeoutSeconds: number?) : Net.Core.NetworkFuture
local NetworkFuture = {}

---@private
---@param networkClient Net.Core.NetworkClient
---@param eventName string
---@param port Net.Core.Port
---@param timeoutSeconds number?
function NetworkFuture:__init(networkClient, eventName, port, timeoutSeconds)
    self.m_eventName = eventName
    self.m_port = port
    self.m_timeoutSeconds = timeoutSeconds
    self.m_networkClient = networkClient

    if type(port) == "number" then
        self.m_networkClient:Open(port)
    end
end

---@async
---@return Net.Core.NetworkContext?
function NetworkFuture:Wait()
    return self.m_networkClient:WaitForEvent(self.m_eventName, self.m_port, self.m_timeoutSeconds)
end

return class("Core.Net.NetworkFuture", NetworkFuture)

]==========],
["Net.Core.NetworkPort"] = [==========[
local Task = require("Core.Common.Task")
local Event = require("Core.Event.init")

---@class Net.Core.NetworkPort : object
---@field Port Net.Core.Port
---@field private m_events table<string, Core.Event>
---@field private m_netClient Net.Core.NetworkClient
---@field private m_logger Core.Logger
---@overload fun(port: Net.Core.Port, logger: Core.Logger, netClient: Net.Core.NetworkClient) : Net.Core.NetworkPort
local NetworkPort = {}

---@private
---@param port Net.Core.Port
---@param logger Core.Logger
---@param netClient Net.Core.NetworkClient
function NetworkPort:__init(port, logger, netClient)
	self.Port = port
	self.m_events = {}
	self.m_logger = logger
	self.m_netClient = netClient
end

---@return table<string, Core.Event>
function NetworkPort:GetEvents()
	return Utils.Table.Copy(self.m_events)
end

---@return integer
function NetworkPort:GetEventsCount()
	return Utils.Table.Count(self.m_events)
end

---@return Net.Core.NetworkClient
function NetworkPort:GetNetClient()
	return self.m_netClient
end

---@param context Net.Core.NetworkContext
function NetworkPort:Execute(context)
	self.m_logger:LogTrace("got triggered with event: '" .. context.EventName .. "'")
	for name, event in pairs(self.m_events) do
		if name == context.EventName or name == 'all' then
			event:Trigger(self.m_logger, context)
		end
		if event:Count() == 0 then
			self:RemoveEvent(name)
		end
	end
end

---@protected
---@param eventName Net.Core.EventName
---@return Core.Event?
function NetworkPort:GetEvent(eventName)
	for name, event in pairs(self.m_events) do
		if name == eventName then
			return event
		end
	end
end

---@protected
---@param eventName Net.Core.EventName
---@return Core.Event
function NetworkPort:CreateOrGetEvent(eventName)
	local event = self:GetEvent(eventName)
	if event then
		return event
	end

	event = Event()
	self.m_events[eventName] = event
	return event
end

---@param onReceivedEventName Net.Core.EventName
---@param listener Core.Task
---@return number taskIndex
function NetworkPort:AddTask(onReceivedEventName, listener)
	local event = self:CreateOrGetEvent(onReceivedEventName)
	return event:AddTask(listener)
end

---@param onReceivedEventName Net.Core.EventName
---@param listener Core.Task
---@return number taskIndex
function NetworkPort:AddTaskOnce(onReceivedEventName, listener)
	local event = self:CreateOrGetEvent(onReceivedEventName)
	return event:AddTaskOnce(listener)
end

---@param eventName Net.Core.EventName
function NetworkPort:RemoveEvent(eventName)
	self.m_events[eventName] = nil
end

---@param eventName string
---@param taskIndex number
function NetworkPort:RemoveTask(eventName, taskIndex)
	local event = self:GetEvent(eventName)
	if not event then
		return
	end

	event:Remove(taskIndex)
end

---@param eventName string
---@param taskIndex number
function NetworkPort:RemoveTaskOnce(eventName, taskIndex)
	local event = self:GetEvent(eventName)
	if not event then
		return
	end

	event:RemoveOnce(taskIndex)
end

---@param eventName string
---@param timeoutSeconds number?
---@return Net.Core.NetworkContext?
function NetworkPort:WaitForEvent(eventName, timeoutSeconds)
	return self.m_netClient:WaitForEvent(eventName, self.Port, timeoutSeconds)
end

function NetworkPort:OpenPort()
	local port = self.Port
	if type(port) == 'number' then
		self.m_netClient:Open(port)
	end
end

function NetworkPort:ClosePort()
	local port = self.Port
	if type(port) == 'number' then
		self.m_netClient:Close(port)
	end
end

---@param ipAddress Net.Core.IPAddress
---@param eventName string
---@param body any
---@param header table<string, any>?
function NetworkPort:SendMessage(ipAddress, eventName, body, header)
	local port = self.Port
	if port == 'all' then
		error('Unable to send a message over all ports')
	end
	---@cast port integer
	self.m_netClient:Send(ipAddress, port, eventName, body, header)
end

---@param eventName string
---@param body any
---@param header table<string, any>?
function NetworkPort:BroadCastMessage(eventName, body, header)
	local port = self.Port
	if port == 'all' then
		error('Unable to broadcast a message over all ports')
	end
	---@cast port integer
	self.m_netClient:BroadCast(port, eventName, body, header)
end

return class("Core.Net.NetworkPort", NetworkPort)

]==========],
["Net.Core.StatusCodes"] = [==========[
---@enum Net.Core.StatusCodes
local StatusCodes = {
	Status100Continue = 100,
	Status101SwitchingProtocols = 101,
	Status102Processing = 102,
	Status200OK = 200,
	Status201Created = 201,
	Status202Accepted = 202,
	Status203NonAuthoritative = 203,
	Status204NoContent = 204,
	Status205ResetContent = 205,
	Status206PartialContent = 206,
	Status207MultiStatus = 207,
	Status208AlreadyReported = 208,
	Status226IMUsed = 226,
	Status300MultipleChoices = 300,
	Status301MovedPermanently = 301,
	Status302Found = 302,
	Status303SeeOther = 303,
	Status304NotModified = 304,
	Status305UseProxy = 305,
	--- RFC 2616, removed
	Status306SwitchProxy = 306,
	Status307TemporaryRedirect = 307,
	Status308PermanentRedirect = 308,
	Status400BadRequest = 400,
	Status401Unauthorized = 401,
	Status402PaymentRequired = 402,
	Status403Forbidden = 403,
	Status404NotFound = 404,
	Status405MethodNotAllowed = 405,
	Status406NotAcceptable = 406,
	Status407ProxyAuthenticationRequired = 407,
	Status408RequestTimeout = 408,
	Status409Conflict = 409,
	Status410Gone = 410,
	Status411LengthRequired = 411,
	Status412PreconditionFailed = 412,
	--- RFC 2616, renamed
	Status413RequestEntityTooLarge = 413,
	--- RFC 7231
	Status413PayloadTooLarge = 413,
	--- RFC 2616, renamed
	Status414RequestUriTooLong = 414,
	--- RFC 7231
	Status414UriTooLong = 414,
	Status415UnsupportedMediaType = 415,
	--- RFC 2616, renamed
	Status416RequestedRangeNotSatisfiable = 416,
	--- RFC 7233
	Status416RangeNotSatisfiable = 416,
	Status417ExpectationFailed = 417,
	Status418ImATeapot = 418,
	--- Not defined in any RFC
	Status419AuthenticationTimeout = 419,
	Status421MisdirectedRequest = 421,
	Status422UnprocessableEntity = 422,
	Status423Locked = 423,
	Status424FailedDependency = 424,
	Status426UpgradeRequired = 426,
	Status428PreconditionRequired = 428,
	Status429TooManyRequests = 429,
	Status431RequestHeaderFieldsTooLarge = 431,
	Status451UnavailableForLegalReasons = 451,
	Status500InternalServerError = 500,
	Status501NotImplemented = 501,
	Status502BadGateway = 502,
	Status503ServiceUnavailable = 503,
	Status504GatewayTimeout = 504,
	Status505HttpVersionNotsupported = 505,
	Status506VariantAlsoNegotiates = 506,
	Status507InsufficientStorage = 507,
	Status508LoopDetected = 508,
	Status510NotExtended = 510,
	Status511NetworkAuthenticationRequired = 511
}

return StatusCodes

]==========],
["Net.Core.Uri"] = [==========[
---@class Net.Rest.Uri : object, Core.Json.ISerializable
---@field private m_path string
---@field private m_query table<string, string>
---@overload fun(paht: string, query: table<string, string>) : Net.Rest.Uri
local Uri = {}

---@param uri string
---@return Net.Rest.Uri uri
function Uri.Static__Parse(uri)
    local splittedUri = Utils.String.Split(uri, "?")
    local path = splittedUri[1]

    local query = {}
    local splittedQuery = Utils.String.Split(splittedUri[2], "&")

    if not splittedQuery == "" then
        for _, queryPart in ipairs(splittedQuery) do
            local splittedQueryPart = Utils.String.Split(queryPart, "=")
            query[splittedQueryPart[1]] = splittedQueryPart[2]
        end
    end

    return Uri(path, query)
end

---@private
---@param path string
---@param query table<string, string>
function Uri:__init(path, query)
    self.m_path = path
    self.m_query = query or {}
end

---@param name string
---@param value string
function Uri:AddToQuery(name, value)
    self.m_query[name] = value
end

---@return string url
function Uri:GetUrl()
    local str = self.m_path
    if #self.m_query > 0 then
        str = str .. "?"
        for name, value in pairs(self.m_query) do
            str = str .. name .. "=" .. value .. "&"
        end
    end
    return str
end

---@private
function Uri:__tostring()
    return self:GetUrl()
end

---@return string path, table<string, string> query
function Uri:Serialize()
    return self.m_path, self.m_query
end

return class("Net.Uri", Uri,
    { Inherit = require("Core.Json.ISerializable") })

]==========],
["Net.Core.Hosting.HostExtensions"] = [==========[
---@type Out<Github_Loading.Module>
local Host = {}
if not PackageLoader:TryGetModule("Hosting.Host", Host) then
    return
end
---@type Hosting.Host
Host = Host.Value:Load()

local Task = require("Core.Common.Task")
local NetworkClient = require("Net.Core.NetworkClient")

---@class Hosting.Host
---@field package m_networkClient Net.Core.NetworkClient
local HostExtensions = {}

---@param networkClient Net.Core.NetworkClient
function HostExtensions:SetNetworkClient(networkClient)
    self.m_networkClient = networkClient
end

---@return Net.Core.NetworkClient
function HostExtensions:GetNetworkClient()
    if not self.m_networkClient then
        self.m_networkClient = NetworkClient(self:CreateLogger("NetworkClient"), nil, self:GetJsonSerializer())
    end

    return self.m_networkClient
end

---@param port Net.Core.Port
---@return Net.Core.NetworkPort networkPort
function HostExtensions:CreateNetworkPort(port)
    return self:GetNetworkClient():GetOrCreateNetworkPort(port)
end

---@param port Net.Core.Port
---@param outNetworkPort Out<Net.Core.NetworkPort>
---@return boolean exists
function HostExtensions:NetworkPortExists(port, outNetworkPort)
    local netPort = self:GetNetworkClient():GetNetworkPort(port)
    if not netPort then
        return false
    end

    outNetworkPort.Value = netPort
    return true
end

---@param port Net.Core.Port
---@return Net.Core.NetworkPort networkPort
function HostExtensions:GetNetworkPort(port)
    ---@type Out<Net.Core.NetworkPort>
    local outNetPort = {}
    if self:NetworkPortExists(port, outNetPort) then
        return outNetPort.Value
    end

    return self:CreateNetworkPort(port)
end

---@param eventName Net.Core.EventName
---@param port Net.Core.Port
---@param task Core.Task
---@return Net.Core.NetworkPort netPort,  number eventTaskIndex
function HostExtensions:AddCallableEventTask(eventName, port, task)
    local netPort = self:CreateNetworkPort(port)
    local taskIndex = netPort:AddTask(eventName, task)
    netPort:OpenPort()
    return netPort, taskIndex
end

---@param eventName Net.Core.EventName
---@param port Net.Core.Port
---@param listener fun(context: Net.Core.NetworkContext)
---@return Net.Core.NetworkPort netPort,  number eventTaskIndex
function HostExtensions:AddCallableEventListener(eventName, port, listener)
    return self:AddCallableEventTask(eventName, port, Task(listener))
end

---@param eventName string
---@param port Net.Core.Port
function HostExtensions:RemoveCallableEvent(eventName, port)
    local netPort = self:GetNetworkPort(port)
    netPort:RemoveEvent(eventName)
end

return Utils.Class.Extend(Host, HostExtensions)

]==========],
}

return Data
