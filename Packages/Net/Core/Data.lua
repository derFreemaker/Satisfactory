---@meta
local PackageData = {}

PackageData["NetCore__events"] = {
    Location = "Net.Core.__events",
    Namespace = "Net.Core.__events",
    IsRunnable = true,
    Data = [[
local JsonSerializer = require("Core.Json.JsonSerializer")

---@class Net.Core.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    JsonSerializer.Static__Serializer:AddTypeInfos({
        -- IPAddress
        require("Net.Core.IPAddress"):Static__GetType(),
    })

    -- Loading Host Extensions
    require("Net.Core.Hosting.HostExtensions")
end

return Events
]]
}

PackageData["NetCoreIPAddress"] = {
    Location = "Net.Core.IPAddress",
    Namespace = "Net.Core.IPAddress",
    IsRunnable = true,
    Data = [[
---@class Net.Core.IPAddress : Core.Json.Serializable
---@field private _Address string
---@overload fun(address: string) : Net.Core.IPAddress
local IPAddress = {}

---@private
---@param address string
function IPAddress:__init(address)
    self._Address = address
end

function IPAddress:GetAddress()
    return self._Address
end

---@private
function IPAddress:__newindex()
    error("Net.Core.IPAddress is read only.")
end

--#region - Serializable -

---@return string address
function IPAddress:Serialize()
    return self._Address
end

--#endregion

return Utils.Class.CreateClass(IPAddress, "Core.IPAddress", require("Core.Json.Serializable"))
]]
}

PackageData["NetCoreMethod"] = {
    Location = "Net.Core.Method",
    Namespace = "Net.Core.Method",
    IsRunnable = true,
    Data = [[
---@enum Net.Core.Method
local Methods = {
	GET = 'GET',
	HEAD = 'HEAD',
	POST = 'POST',
	PUT = 'PUT',
	CREATE = 'CREATE',
	DELETE = 'DELETE',
	CONNECT = 'CONNECT',
	OPTIONS = 'OPTIONS',
	TRACE = 'TRACE',
	PATCH = 'PATCH'
}

return Methods
]]
}

PackageData["NetCoreNetworkClient"] = {
    Location = "Net.Core.NetworkClient",
    Namespace = "Net.Core.NetworkClient",
    IsRunnable = true,
    Data = [[
local NetworkCardAdapter = require('Adapter.Computer.NetworkCard')
local JsonSerializer = require('Core.Json.JsonSerializer')
local EventPullAdapter = require('Core.Event.EventPullAdapter')
local Task = require('Core.Task')
local NetworkPort = require('Net.Core.NetworkPort')
local NetworkContext = require('Net.Core.NetworkContext')

local IPAddress = require("Net.Core.IPAddress")

---@class Net.Core.NetworkClient : object
---@field private _IPAddress Net.Core.IPAddress
---@field private _Ports Dictionary<integer | "all", Net.Core.NetworkPort>
---@field private _NetworkCard Adapter.Computer.NetworkCard
---@field private _Serializer Core.Json.Serializer
---@field private _Logger Core.Logger
---@overload fun(logger: Core.Logger, networkCard: Adapter.Computer.NetworkCard?, serializer: Core.Json.Serializer?) : Net.Core.NetworkClient
local NetworkClient = {}

---@private
---@param logger Core.Logger
---@param networkCard Adapter.Computer.NetworkCard?
---@param serializer Core.Json.Serializer?
function NetworkClient:__init(logger, networkCard, serializer)
	networkCard = networkCard or NetworkCardAdapter(1)

	self._Logger = logger
	self._Ports = {}
	self._NetworkCard = networkCard

	self._Serializer = serializer or JsonSerializer.Static__Serializer

	self._NetworkCard:Listen()
	EventPullAdapter:AddListener('NetworkMessage', Task(self.networkMessageRecieved, self))
end

---@return Net.Core.IPAddress
function NetworkClient:GetIPAddress()
	if self._IPAddress then
		return self._IPAddress
	end

	self._IPAddress = IPAddress(self._NetworkCard:GetIPAddress())
	return self._IPAddress
end

---@return string nick
function NetworkClient:GetNick()
	return self._NetworkCard:GetNick()
end

---@private
---@param data any[]
function NetworkClient:networkMessageRecieved(data)
	local context = NetworkContext(data, self._Serializer)
	self._Logger:LogDebug("recieved network message with event: '" ..
		context.EventName .. "' on port: '" .. context.Port .. "'")
	for i, port in pairs(self._Ports) do
		if port.Port == context.Port or port.Port == 'all' then
			port:Execute(context)
		end
		if port:GetEventsCount() == 0 then
			port:ClosePort()
		end
	end
end

---@param port (integer | "all")?
---@return Net.Core.NetworkPort
function NetworkClient:GetOrCreateNetworkPort(port)
	port = port or 'all'

	local networkPort = self:GetNetworkPort(port)
	if networkPort then
		return networkPort
	end

	networkPort = NetworkPort(port, self._Logger:subLogger('NetworkPort[' .. port .. ']'), self)
	self._Ports[port] = networkPort
	return networkPort
end

---@param port integer | "all"
---@return Net.Core.NetworkPort?
function NetworkClient:GetNetworkPort(port)
	for portNumber, networkPort in pairs(self._Ports) do
		if portNumber == port then
			return networkPort
		end
	end
	return nil
end

---@param onRecivedEventName (string | "all")?
---@param onRecivedPort (integer | "all")?
---@param listener Core.Task
---@return Net.Core.NetworkPort
function NetworkClient:AddListener(onRecivedEventName, onRecivedPort, listener)
	onRecivedEventName = onRecivedEventName or 'all'
	onRecivedPort = onRecivedPort or 'all'

	local networkPort = self:GetOrCreateNetworkPort(onRecivedPort)
	networkPort:AddListener(onRecivedEventName, listener)
	return networkPort
end

NetworkClient.On = NetworkClient.AddListener

---@param onRecivedEventName string | "all"
---@param onRecivedPort integer | "all"
---@param listener Core.Task
---@return Net.Core.NetworkPort
function NetworkClient:AddListenerOnce(onRecivedEventName, onRecivedPort, listener)
	onRecivedEventName = onRecivedEventName or 'all'
	onRecivedPort = onRecivedPort or 'all'

	local networkPort = self:GetOrCreateNetworkPort(onRecivedPort)
	networkPort:AddListenerOnce(onRecivedEventName, listener)
	return networkPort
end

NetworkClient.Once = NetworkClient.AddListenerOnce

---@param eventName string | "all"
---@param port integer | "all"
---@param timeoutSeconds number?
---@return Net.Core.NetworkContext?
function NetworkClient:WaitForEvent(eventName, port, timeoutSeconds)
	self._Logger:LogDebug("waiting for event: '" .. eventName .. "' on port: " .. port)
	local result
	---@param context Net.Core.NetworkContext
	local function set(context)
		result = context
	end
	self:AddListenerOnce(eventName, port, Task(set)):OpenPort()
	repeat
		if not EventPullAdapter:Wait(timeoutSeconds) then
			break
		end
	until result ~= nil
	return result
end

---@param port integer
function NetworkClient:Open(port)
	self._NetworkCard:OpenPort(port)
	self._Logger:LogTrace('opened Port: ' .. port)
end

---@param port integer
function NetworkClient:Close(port)
	self._NetworkCard:ClosePort(port)
	self._Logger:LogTrace('closed Port: ' .. port)
end

function NetworkClient:CloseAll()
	self._NetworkCard:CloseAllPorts()
	self._Logger:LogTrace('closed all Ports')
end

---@param ipAddress Net.Core.IPAddress
---@param port integer
---@param eventName string
---@param body any
---@param header Dictionary<string, any>?
function NetworkClient:Send(ipAddress, port, eventName, body, header)
	local jsonBody = self._Serializer:Serialize(body)
	local jsonHeader = self._Serializer:Serialize(header)

	self._NetworkCard:Send(ipAddress, port, eventName, jsonBody, jsonHeader)
end

---@param port integer
---@param eventName string
---@param body any
---@param header Dictionary<string, any>?
function NetworkClient:BroadCast(port, eventName, body, header)
	local jsonBody = self._Serializer:Serialize(body)
	local jsonHeader = self._Serializer:Serialize(header)

	self._NetworkCard:BroadCast(port, eventName, jsonBody, jsonHeader)
end

return Utils.Class.CreateClass(NetworkClient, 'Core.Net.NetworkClient')
]]
}

PackageData["NetCoreNetworkContext"] = {
    Location = "Net.Core.NetworkContext",
    Namespace = "Net.Core.NetworkContext",
    IsRunnable = true,
    Data = [[
local JsonSerializer = require('Core.Json.JsonSerializer')
local IPaddress = require("Net.Core.IPAddress")

---@class Net.Core.NetworkContext : object
---@field SignalName string
---@field SignalSender Satisfactory.Components.Object
---@field SenderIPAddress Net.Core.IPAddress
---@field Port integer
---@field EventName string
---@field Header Dictionary<string, any>
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
	self.Header = serializer:Deserialize(data[7] or 'null')
	self.Body = serializer:Deserialize(data[6] or 'null')
end

return Utils.Class.CreateClass(NetworkContext, 'Core.Net.NetworkContext')
]]
}

PackageData["NetCoreNetworkPort"] = {
    Location = "Net.Core.NetworkPort",
    Namespace = "Net.Core.NetworkPort",
    IsRunnable = true,
    Data = [[
local Event = require('Core.Event.Event')

---@class Net.Core.NetworkPort : object
---@field Port integer | "all"
---@field private _Events Dictionary<string, Core.Event>
---@field private _NetClient Net.Core.NetworkClient
---@field private _Logger Core.Logger
---@overload fun(port: integer | "all", logger: Core.Logger, netClient: Net.Core.NetworkClient) : Net.Core.NetworkPort
local NetworkPort = {}

---@private
---@param port integer | "all"
---@param logger Core.Logger
---@param netClient Net.Core.NetworkClient
function NetworkPort:__init(port, logger, netClient)
	self.Port = port
	self._Events = {}
	self._Logger = logger
	self._NetClient = netClient
end

---@return Dictionary<string, Core.Event>
function NetworkPort:GetEvents()
	return Utils.Table.Copy(self._Events)
end

---@return integer
function NetworkPort:GetEventsCount()
	return Utils.Table.Count(self._Events)
end

---@return Net.Core.NetworkClient
function NetworkPort:GetNetClient()
	return self._NetClient
end

---@param context Net.Core.NetworkContext
function NetworkPort:Execute(context)
	self._Logger:LogTrace("got triggered with event: '" .. context.EventName .. "'")
	for name, event in pairs(self._Events) do
		if name == context.EventName or name == 'all' then
			event:Trigger(self._Logger, context)
		end
		if event:GetCount() == 0 then
			self._Events[name] = nil
		end
	end
end

---@protected
---@param eventName string | "all"
---@return Core.Event?
function NetworkPort:GetEvent(eventName)
	for name, event in pairs(self._Events) do
		if name == eventName then
			return event
		end
	end
end

---@protected
---@param eventName string | "all"
---@return Core.Event
function NetworkPort:CreateOrGetEvent(eventName)
	local event = self:GetEvent(eventName)
	if event then
		return event
	end

	event = Event()
	self._Events[eventName] = event
	return event
end

---@param onRecivedEventName string | "all"
---@param listener Core.Task
---@return Net.Core.NetworkPort
function NetworkPort:AddListener(onRecivedEventName, listener)
	local event = self:CreateOrGetEvent(onRecivedEventName)
	event:AddListener(listener)
	return self
end

---@param onRecivedEventName string | "all"
---@param listener Core.Task
---@return Net.Core.NetworkPort
function NetworkPort:AddListenerOnce(onRecivedEventName, listener)
	local event = self:CreateOrGetEvent(onRecivedEventName)
	event:AddListenerOnce(listener)
	return self
end

---@param eventName string | "all"
function NetworkPort:RemoveListener(eventName)
	local event = self:GetEvent(eventName)
	if not event then
		return
	end

	self._Events[eventName] = nil
end

---@param eventName string
---@param timeoutSeconds number?
---@return Net.Core.NetworkContext?
function NetworkPort:WaitForEvent(eventName, timeoutSeconds)
	return self._NetClient:WaitForEvent(eventName, self.Port, timeoutSeconds)
end

function NetworkPort:OpenPort()
	local port = self.Port
	if type(port) == 'number' then
		self._NetClient:Open(port)
	end
end

function NetworkPort:ClosePort()
	local port = self.Port
	if type(port) == 'number' then
		self._NetClient:Close(port)
	end
end

---@param ipAddress Net.Core.IPAddress
---@param eventName string
---@param body any
---@param header Dictionary<string, any>?
function NetworkPort:SendMessage(ipAddress, eventName, body, header)
	local port = self.Port
	if port == 'all' then
		error('Unable to send a message over all ports')
	end
	---@cast port integer
	self._NetClient:Send(ipAddress, port, eventName, body, header)
end

---@param eventName string
---@param body any
---@param header Dictionary<string, any>?
function NetworkPort:BroadCastMessage(eventName, body, header)
	local port = self.Port
	if port == 'all' then
		error('Unable to broadcast a message over all ports')
	end
	---@cast port integer
	self._NetClient:BroadCast(port, eventName, body, header)
end

return Utils.Class.CreateClass(NetworkPort, 'Core.Net.NetworkPort')
]]
}

PackageData["NetCoreStatusCodes"] = {
    Location = "Net.Core.StatusCodes",
    Namespace = "Net.Core.StatusCodes",
    IsRunnable = true,
    Data = [[
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
]]
}

PackageData["NetCoreHostingHostExtensions"] = {
    Location = "Net.Core.Hosting.HostExtensions",
    Namespace = "Net.Core.Hosting.HostExtensions",
    IsRunnable = true,
    Data = [[
local NetworkClient = require("Net.Core.NetworkClient")

---@class Hosting.Host
---@field private _NetworkClient Net.Core.NetworkClient
local HostExtensions = {}

---@private
function HostExtensions:CheckNetworkClient()
    if self._NetworkClient then
        return
    end

    self._NetworkClient = NetworkClient(self._Logger:subLogger("NetworkClient"), nil, self._JsonSerializer)
end

---@param networkClient Net.Core.NetworkClient
function HostExtensions:SetNetworkClient(networkClient)
    self._NetworkClient = networkClient
end

---@return Net.Core.NetworkClient
function HostExtensions:GetNetworkClient()
    self:CheckNetworkClient()

    return self._NetworkClient
end

---@param port integer | "all"
---@return Net.Core.NetworkPort networkPort
function HostExtensions:CreateNetworkPort(port)
    self:CheckNetworkClient()

    return self._NetworkClient:GetOrCreateNetworkPort(port)
end

---@param port integer | "all"
---@param outNetworkPort Out<Net.Core.NetworkPort>
---@return boolean exists
function HostExtensions:NetworkPortExists(port, outNetworkPort)
    self:CheckNetworkClient()

    local netPort = self._NetworkClient:GetNetworkPort(port)
    if not netPort then
        return false
    end

    outNetworkPort.Return = netPort
    return true
end

---@param port integer | "all"
---@return Net.Core.NetworkPort networkPort
function HostExtensions:GetNetworkPort(port)
    ---@type Out<Net.Core.NetworkPort>
    local outNetPort = {}
    if self:NetworkPortExists(port, outNetPort) then
        return outNetPort.Return
    end

    return self:CreateNetworkPort(port)
end

---@param eventName string
---@param port integer | "all"
---@param task Core.Task
function HostExtensions:AddCallableEvent(eventName, port, task)
    local netPort = self:CreateNetworkPort(port)
    netPort:AddListener(eventName, task)
    netPort:OpenPort()
end

---@param eventName string
---@param port integer | "all"
function HostExtensions:RemoveCallableEvent(eventName, port)
    local netPort = self:GetNetworkPort(port)
    netPort:RemoveListener(eventName)
end

return Utils.Class.ExtendClass(HostExtensions, require("Hosting.Host") --{{{@as Hosting.Host}}})
]]
}

return PackageData
