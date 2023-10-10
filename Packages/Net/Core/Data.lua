local PackageData = {}

PackageData[-1058189529] = {
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

PackageData[-810495773] = {
    Location = "Net.Core.NetworkClient",
    Namespace = "Net.Core.NetworkClient",
    IsRunnable = true,
    Data = [[
local NetworkCardAdapter = require('Adapter.Computer.NetworkCard')
local Json = require('Core.Json')
local EventPullAdapter = require('Core.Event.EventPullAdapter')
local Task = require('Core.Task')
local NetworkPort = require('Net.Core.NetworkPort')
local NetworkContext = require('Net.Core.NetworkContext')

---@class Net.Core.NetworkClient : object
---@field private Logger Core.Logger
---@field private ports Dictionary<integer | "all", Net.Core.NetworkPort>
---@field private networkCard Adapter.Computer.NetworkCard
---@overload fun(logger: Core.Logger, networkCard: Adapter.Computer.NetworkCard?) : Net.Core.NetworkClient
local NetworkClient = {}

---@private
---@param logger Core.Logger
---@param networkCard Adapter.Computer.NetworkCard?
function NetworkClient:__init(logger, networkCard)
	networkCard = networkCard or NetworkCardAdapter(1)

	self.Logger = logger
	self.ports = {}
	self.networkCard = networkCard

	networkCard:Listen()
	EventPullAdapter:AddListener('NetworkMessage', Task(self.networkMessageRecieved, self))
end

---@return FicsIt_Networks.UUID
function NetworkClient:GetId()
	return self.networkCard:GetId()
end

---@private
---@param data any[]
function NetworkClient:networkMessageRecieved(data)
	local context = NetworkContext(data)
	self.Logger:LogDebug("recieved network message with event: '" ..
		context.EventName .. "' on port: '" .. context.Port .. "'")
	for i, port in pairs(self.ports) do
		if port.Port == context.Port or port.Port == 'all' then
			port:Execute(context)
		end
		if port:GetEventsCount() == 0 then
			port:ClosePort()
		end
	end
end

---@param port integer | "all"
---@return Net.Core.NetworkPort?
function NetworkClient:GetNetworkPort(port)
	for portNumber, networkPort in pairs(self.ports) do
		if portNumber == port then
			return networkPort
		end
	end
	return nil
end

---@param port integer | "all"
---@return Net.Core.NetworkPort
function NetworkClient:GetOrCreateNetworkPort(port)
	return self:GetNetworkPort(port) or self:CreateNetworkPort(port)
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

---@param port (integer | "all")?
---@return Net.Core.NetworkPort
function NetworkClient:CreateNetworkPort(port)
	port = port or 'all'

	local networkPort = self:GetNetworkPort(port)
	if networkPort then
		return networkPort
	end

	networkPort = NetworkPort(port, self.Logger:subLogger('NetworkPort[' .. port .. ']'), self)
	self.ports[port] = networkPort
	return networkPort
end

---@param eventName string | "all"
---@param port integer | "all"
---@param timeout number?
---@return Net.Core.NetworkContext?
function NetworkClient:WaitForEvent(eventName, port, timeout)
	self.Logger:LogDebug("waiting for event: '" .. eventName .. "' on port: " .. port)
	local result
	---@param context Net.Core.NetworkContext
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
function NetworkClient:Open(port)
	self.networkCard:OpenPort(port)
	self.Logger:LogTrace('opened Port: ' .. port)
end

---@param port integer
function NetworkClient:Close(port)
	self.networkCard:ClosePort(port)
	self.Logger:LogTrace('closed Port: ' .. port)
end

function NetworkClient:CloseAll()
	self.networkCard:CloseAllPorts()
	self.Logger:LogTrace('closed all Ports')
end

---@param ipAddress string
---@param port integer
---@param eventName string
---@param body any
---@param header Dictionary<string, any>?
function NetworkClient:Send(ipAddress, port, eventName, body, header)
	self.networkCard:Send(ipAddress, port, eventName, Json.encode(body), Json.encode(header or {}))
end

---@param port integer
---@param eventName string
---@param body any
---@param header Dictionary<string, any>?
function NetworkClient:BroadCast(port, eventName, body, header)
	self.networkCard:BroadCast(port, eventName, Json.encode(body), Json.encode(header or {}))
end

return Utils.Class.CreateClass(NetworkClient, 'Core.Net.NetworkClient')
]]
}

PackageData[108999106] = {
    Location = "Net.Core.NetworkContext",
    Namespace = "Net.Core.NetworkContext",
    IsRunnable = true,
    Data = [[
local Json = require('Core.Json')

---@class Net.Core.NetworkContext : object
---@field SignalName string
---@field SignalSender FicsIt_Networks.Components.Object
---@field SenderIPAddress string
---@field Port integer
---@field EventName string
---@field Header Dictionary<string, any>
---@field Body any
---@overload fun(data: any[]) : Net.Core.NetworkContext
local NetworkContext = {}

---@private
---@param data any[]
function NetworkContext:__init(data)
	self.SignalName = data[1]
	self.SignalSender = data[2]
	self.SenderIPAddress = data[3]
	self.Port = data[4]
	self.EventName = data[5]
	self.Header = Json.decode(data[7] or 'null')
	self.Body = Json.decode(data[6] or 'null')
end

return Utils.Class.CreateClass(NetworkContext, 'Core.Net.NetworkContext')
]]
}

PackageData[1890077625] = {
    Location = "Net.Core.NetworkPort",
    Namespace = "Net.Core.NetworkPort",
    IsRunnable = true,
    Data = [[
local Event = require('Core.Event.Event')

---@class Net.Core.NetworkPort : object
---@field Port integer | "all"
---@field private events Dictionary<string, Core.Event>
---@field private netClient Net.Core.NetworkClient
---@field private logger Core.Logger
---@overload fun(port: integer | "all", logger: Core.Logger, netClient: Net.Core.NetworkClient) : Net.Core.NetworkPort
local NetworkPort = {}

---@private
---@param port integer | "all"
---@param logger Core.Logger
---@param netClient Net.Core.NetworkClient
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

---@return integer
function NetworkPort:GetEventsCount()
	return #self.events
end

---@return Net.Core.NetworkClient
function NetworkPort:GetNetClient()
	return self.netClient
end

---@param context Net.Core.NetworkContext
function NetworkPort:Execute(context)
	self.logger:LogTrace("got triggered with event: '" .. context.EventName .. "'")
	for name, event in pairs(self.events) do
		if name == context.EventName or name == 'all' then
			event:Trigger(self.logger, context)
		end
		if event:GetCount() == 0 then
			self.events[name] = nil
		end
	end
end

---@protected
---@param eventName string | "all"
---@return Core.Event
function NetworkPort:CreateOrGetEvent(eventName)
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
---@return Net.Core.NetworkPort
function NetworkPort:AddListener(onRecivedEventName, listener)
	local event = self:CreateOrGetEvent(onRecivedEventName)
	event:AddListener(listener)
	return self
end

NetworkPort.On = NetworkPort.AddListener

---@param onRecivedEventName string | "all"
---@param listener Core.Task
---@return Net.Core.NetworkPort
function NetworkPort:AddListenerOnce(onRecivedEventName, listener)
	local event = self:CreateOrGetEvent(onRecivedEventName)
	event:AddListenerOnce(listener)
	return self
end

NetworkPort.Once = NetworkPort.AddListenerOnce

---@param eventName string
---@param timeout number?
---@return Net.Core.NetworkContext?
function NetworkPort:WaitForEvent(eventName, timeout)
	return self.netClient:WaitForEvent(eventName, self.Port, timeout)
end

function NetworkPort:OpenPort()
	local port = self.Port
	if type(port) == 'number' then
		self.netClient:Open(port)
	end
end

function NetworkPort:ClosePort()
	local port = self.Port
	if type(port) == 'number' then
		self.netClient:Close(port)
	end
end

---@param ipAddress string
---@param eventName string
---@param body any
---@param header Dictionary<string, any>?
function NetworkPort:SendMessage(ipAddress, eventName, body, header)
	local port = self.Port
	if port == 'all' then
		error('Unable to send a message over all ports')
	end
	---@cast port integer
	self.netClient:Send(ipAddress, port, eventName, body, header)
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
	self.netClient:BroadCast(port, eventName, body, header)
end

return Utils.Class.CreateClass(NetworkPort, 'Core.Net.NetworkPort')
]]
}

PackageData[256538919] = {
    Location = "Net.Core.StatusCodes",
    Namespace = "Net.Core.StatusCodes",
    IsRunnable = true,
    Data = [[
---@enum Net.Core.StatusCodes
local StatusCodes = {
	StatusCode100Continue = 100,
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

return PackageData
