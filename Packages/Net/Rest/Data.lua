---@meta
local PackageData = {}

PackageData["NetRest__events"] = {
    Location = "Net.Rest.__events",
    Namespace = "Net.Rest.__events",
    IsRunnable = true,
    Data = [[
---@class Net.Rest.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    require("Net.Rest.Api.NetworkContextExtensions")
    require("Net.Rest.Hosting.HostExtensions")
end

return Events
]]
}

PackageData["NetRestApiNetworkContextExtensions"] = {
    Location = "Net.Rest.Api.NetworkContextExtensions",
    Namespace = "Net.Rest.Api.NetworkContextExtensions",
    IsRunnable = true,
    Data = [[
local NetworkContext = require("Net.Core.NetworkContext")
local Request = require('Net.Rest.Api.Request')
local Response = require('Net.Rest.Api.Response')

---@class Net.Core.NetworkContext
local NetworkContextExtensions = {}

--- ## Extension from Net.Rest
---@return Net.Rest.Api.Request
function NetworkContextExtensions:ToApiRequest()
	return Request(self.Body.Method, self.Body.Endpoint, self.Body.Body, self.Body.Headers)
end

--- ## Extension from Net.Rest
---@return Net.Rest.Api.Response
function NetworkContextExtensions:ToApiResponse()
	return Response(self.Body.Body, self.Body.Headers)
end

Utils.Class.ExtendClass(NetworkContextExtensions, NetworkContext --{{{@as Net.Core.NetworkContext}}})
]]
}

PackageData["NetRestApiRequest"] = {
    Location = "Net.Rest.Api.Request",
    Namespace = "Net.Rest.Api.Request",
    IsRunnable = true,
    Data = [[
---@class Net.Rest.Api.Request : object
---@field Method Net.Core.Method
---@field Endpoint string
---@field Headers Dictionary<string, any>
---@field Body any
---@overload fun(method: Net.Core.Method, endpoint: string, body: any, headers: Dictionary<string, any>?) : Net.Rest.Api.Request
local Request = {}

---@private
---@param method Net.Core.Method
---@param endpoint string
---@param body any
---@param headers Dictionary<string, any>?
function Request:__init(method, endpoint, body, headers)
	self.Method = method
	self.Endpoint = endpoint
	self.Headers = headers or {}
	self.Body = body
end

---@return table
function Request:ExtractData()
	return {
		Method = self.Method,
		Endpoint = self.Endpoint,
		Headers = self.Headers,
		Body = self.Body
	}
end

return Utils.Class.CreateClass(Request, 'Net.Rest.Api.Request')
]]
}

PackageData["NetRestApiResponse"] = {
    Location = "Net.Rest.Api.Response",
    Namespace = "Net.Rest.Api.Response",
    IsRunnable = true,
    Data = [[
---@class Net.Rest.Api.Response.Header
---@field Code Net.Core.StatusCodes

---@class Net.Rest.Api.Response
---@field Headers Net.Rest.Api.Response.Header | Dictionary<string, any>
---@field Body any
---@field WasSuccessfull boolean
---@overload fun(body: any, header: (Net.Rest.Api.Response.Header | Dictionary<string, any>)?) : Net.Rest.Api.Response
local Response = {}

---@private
---@param body any
---@param header (Net.Rest.Api.Response.Header | Dictionary<string, any>)?
function Response:__init(body, header)
	self.Headers = header or {}
	self.Body = body
	if type(self.Headers.Code) == 'number' then
		self.WasSuccessfull = self.Headers.Code < 300
	else
		self.WasSuccessfull = false
	end
end

---@return table
function Response:ExtractData()
	return {
		Headers = self.Headers,
		Body = self.Body
	}
end

return Utils.Class.CreateClass(Response, 'Net.Rest.Api.Response')
]]
}

PackageData["NetRestApiClientClient"] = {
    Location = "Net.Rest.Api.Client.Client",
    Namespace = "Net.Rest.Api.Client.Client",
    IsRunnable = true,
    Data = [[
local EventNameUsage = require("Core.Usage.Usage_EventName")

local Response = require('Net.Rest.Api.Response')

---@class Net.Rest.Api.Client : object
---@field ServerIPAddress Net.Core.IPAddress
---@field ServerPort integer
---@field ReturnPort integer
---@field private _NetClient Net.Core.NetworkClient
---@field private _Logger Core.Logger
---@overload fun(serverIPAddress: Net.Core.IPAddress, serverPort: integer, returnPort: integer, netClient: Net.Core.NetworkClient, logger: Core.Logger) : Net.Rest.Api.Client
local Client = {}

---@private
---@param serverIPAddress Net.Core.IPAddress
---@param serverPort integer
---@param returnPort integer
---@param netClient Net.Core.NetworkClient
---@param logger Core.Logger
function Client:__init(serverIPAddress, serverPort, returnPort, netClient, logger)
	self.ServerIPAddress = serverIPAddress
	self.ServerPort = serverPort
	self.ReturnPort = returnPort
	self._NetClient = netClient
	self._Logger = logger
end

---@param request Net.Rest.Api.Request
---@param timeout integer?
---@return Net.Rest.Api.Response response
function Client:Send(request, timeout)
	self._NetClient:Send(self.ServerIPAddress, self.ServerPort, EventNameUsage.RestRequest, request:ExtractData(),
		{ ReturnPort = self.ReturnPort })
	local context = self._NetClient:WaitForEvent(EventNameUsage.RestResponse, self.ReturnPort, timeout or 5)
	if not context then
		return Response(nil, { Code = 408 })
	end

	local response = context:ToApiResponse()
	return response
end

return Utils.Class.CreateClass(Client, 'Net.Rest.Api.Client')
]]
}

PackageData["NetRestApiServerController"] = {
    Location = "Net.Rest.Api.Server.Controller",
    Namespace = "Net.Rest.Api.Server.Controller",
    IsRunnable = true,
    Data = [[
local EventNameUsage = require("Core.Usage.Usage_EventName")

local Task = require('Core.Task')
local RestApiEndpoint = require('Net.Rest.Api.Server.Endpoint')
local RestApiResponseTemplates = require('Net.Rest.Api.Server.ResponseTemplates')
local RestApiMethod = require('Net.Core.Method')

---@class Net.Rest.Api.Server.Controller : object
---@field private _Endpoints Dictionary<Net.Core.Method, Dictionary<string, Net.Rest.Api.Server.Endpoint>>
---@field private _NetPort Net.Core.NetworkPort
---@field private _Logger Core.Logger
---@overload fun(netPort: Net.Core.NetworkPort, logger: Core.Logger) : Net.Rest.Api.Server.Controller
local Controller = {}

---@private
---@param netPort Net.Core.NetworkPort
---@param logger Core.Logger
function Controller:__init(netPort, logger)
	self._Endpoints = {}
	self._NetPort = netPort
	self._Logger = logger
	netPort:AddListener('Rest-Request', Task(self.onMessageRecieved, self))
end

---@private
---@param context Net.Core.NetworkContext
function Controller:onMessageRecieved(context)
	local request = context:ToApiRequest()
	self._Logger:LogDebug("recieved request on endpoint: '" .. request.Endpoint .. "'")
	local endpoint = self:GetEndpoint(request.Method, request.Endpoint)
	if endpoint == nil then
		self._Logger:LogTrace('found no endpoint')
		if context.Header.ReturnPort then
			self._NetPort:GetNetClient():Send(
				context.SenderIPAddress,
				context.Header.ReturnPort,
				EventNameUsage.RestResponse,
				RestApiResponseTemplates.NotFound('Unable to find endpoint'):ExtractData())
		end
		return
	end
	self._Logger:LogTrace('found endpoint: ' .. request.Endpoint)
	endpoint:Execute(request, context, self._NetPort:GetNetClient())
end

---@param endpointMethod Net.Core.Method
---@return Dictionary<string, Net.Rest.Api.Server.Endpoint>?
function Controller:GetSubEndpoints(endpointMethod)
	for method, subEndpoints in pairs(self._Endpoints) do
		if method == endpointMethod then
			return subEndpoints
		end
	end
end

---@param endpointMethod Net.Core.Method
---@param endpointName string
---@return Net.Rest.Api.Server.Endpoint?
function Controller:GetEndpoint(endpointMethod, endpointName)
	local subEndpoints = self:GetSubEndpoints(endpointMethod)

	if not subEndpoints then
		return
	end

	for name, endpoint in pairs(subEndpoints) do
		if name == endpointName then
			return endpoint
		end
	end
end

---@param method Net.Core.Method
---@param name string
---@param task Core.Task
---@return Net.Rest.Api.Server.Controller
function Controller:AddEndpoint(method, name, task)
	if self:GetEndpoint(method, name) ~= nil then
		error('Endpoint allready exists')
	end

	local subEndpoints = self:GetSubEndpoints(method)

	if not subEndpoints then
		subEndpoints = {}
		self._Endpoints[method] = subEndpoints
	end

	subEndpoints[name] = RestApiEndpoint(task, self._Logger:subLogger("RestApiEndpoint[" .. method .. ":" .. name .. "]"))
	self._Logger:LogTrace("Added endpoint: " .. method .. ":" .. name)
	return self
end

---@param endpoint Net.Rest.Api.Server.EndpointBase
function Controller:AddEndpointBase(endpoint)
	for name, func in next, endpoint, nil do
		if type(name) == 'string' and type(func) == 'function' then
			local method,
			endpointName = name:match('^(.+)__(.+)$')
			if method ~= nil and endpoint ~= nil and RestApiMethod[method] then
				self:AddEndpoint(method, endpointName, Task(func, endpoint))
			end
		end
	end
end

return Utils.Class.CreateClass(Controller, 'Net.Rest.Api.Server.Controller')
]]
}

PackageData["NetRestApiServerEndpoint"] = {
    Location = "Net.Rest.Api.Server.Endpoint",
    Namespace = "Net.Rest.Api.Server.Endpoint",
    IsRunnable = true,
    Data = [[
local EventNameUsage = require("Core.Usage.Usage_EventName")

local RestApiResponseTemplates = require('Net.Rest.Api.Server.ResponseTemplates')

---@class Net.Rest.Api.Server.Endpoint : object
---@field private _Task Core.Task
---@field private _Logger Core.Logger
---@overload fun(task: Core.Task, logger: Core.Logger) : Net.Rest.Api.Server.Endpoint
local Endpoint = {}

---@private
---@param task Core.Task
---@param logger Core.Logger
function Endpoint:__init(task, logger)
	self._Task = task
	self._Logger = logger
end

---@param request Net.Rest.Api.Request
---@param context Net.Core.NetworkContext
---@param netClient Net.Core.NetworkClient
function Endpoint:Execute(request, context, netClient)
	self._Logger:LogTrace('executing...')
	___logger:setLogger(self._Logger)
	self._Task:Execute(request)
	self._Task:LogError(self._Logger)
	___logger:revert()
	---@type Net.Rest.Api.Response
	local response = self._Task:GetResults()
	if not self._Task:IsSuccess() then
		response = RestApiResponseTemplates.InternalServerError(tostring(self._Task:GetTraceback()))
	end
	if context.Header.ReturnPort then
		self._Logger:LogTrace("sending response to '" ..
			context.SenderIPAddress .. "' on port: " .. context.Header.ReturnPort .. '...')
		netClient:Send(
			context.SenderIPAddress,
			context.Header.ReturnPort,
			EventNameUsage.RestResponse,
			response:ExtractData()
		)
	else
		self._Logger:LogTrace('sending no response')
	end
	if response.Headers.Message == nil then
		self._Logger:LogDebug('request finished with status code: ' .. response.Headers.Code)
	else
		self._Logger:LogDebug('request finished with status code: ' ..
			response.Headers.Code .. " with message: '" .. response.Headers.Message .. "'")
	end
end

return Utils.Class.CreateClass(Endpoint, 'Net.Rest.Api.Server.Endpoint')
]]
}

PackageData["NetRestApiServerEndpointBase"] = {
    Location = "Net.Rest.Api.Server.EndpointBase",
    Namespace = "Net.Rest.Api.Server.EndpointBase",
    IsRunnable = true,
    Data = [[
local RestApiResponseTemplates = require('Net.Rest.Api.Server.ResponseTemplates')

---@class Net.Rest.Api.Server.EndpointBase : object
---@field protected Templates Core.Rest.Api.Server.EndpointBase.ResponseTemplates
local EndpointBase = {}

---@class Core.Rest.Api.Server.EndpointBase.ResponseTemplates
local Templates = {}

---@param value any
---@return Net.Rest.Api.Response
function Templates:Ok(value)
	return RestApiResponseTemplates.Ok(value)
end

---@param message string
---@return Net.Rest.Api.Response
function Templates:BadRequest(message)
	return RestApiResponseTemplates.BadRequest(message)
end

---@param message string
---@return Net.Rest.Api.Response
function Templates:NotFound(message)
	return RestApiResponseTemplates.NotFound(message)
end

---@param message string
---@return Net.Rest.Api.Response
function Templates:InternalServerError(message)
	return RestApiResponseTemplates.InternalServerError(message)
end

EndpointBase.Templates = Templates

return Utils.Class.CreateClass(EndpointBase, 'Net.Rest.Api.Server.EndpointBase')
]]
}

PackageData["NetRestApiServerResponseTemplates"] = {
    Location = "Net.Rest.Api.Server.ResponseTemplates",
    Namespace = "Net.Rest.Api.Server.ResponseTemplates",
    IsRunnable = true,
    Data = [[
local StatusCodes = require('Net.Core.StatusCodes')
local RestApiResponse = require('Net.Rest.Api.Response')

---@class Net.Rest.Api.Server.RestApiResponseTemplates
local ResponseTemplates = {}

---@param value any
---@return Net.Rest.Api.Response
function ResponseTemplates.Ok(value)
	return RestApiResponse(value, { Code = StatusCodes.Status200OK })
end

function ResponseTemplates.Accepted(value)
	return RestApiResponse(value, { Core = StatusCodes.Status202Accepted })
end

---@param message string
---@return Net.Rest.Api.Response
function ResponseTemplates.BadRequest(message)
	return RestApiResponse(nil, { Code = StatusCodes.Status400BadRequest, Message = message })
end

---@param message string
---@return Net.Rest.Api.Response
function ResponseTemplates.NotFound(message)
	return RestApiResponse(nil, { Code = StatusCodes.Status404NotFound, Message = message })
end

---@param message string
---@return Net.Rest.Api.Response
function ResponseTemplates.InternalServerError(message)
	return RestApiResponse(nil, { Code = StatusCodes.Status500InternalServerError, Message = message })
end

return ResponseTemplates
]]
}

PackageData["NetRestHostingHostExtensions"] = {
    Location = "Net.Rest.Hosting.HostExtensions",
    Namespace = "Net.Rest.Hosting.HostExtensions",
    IsRunnable = true,
    Data = [[
local ApiController = require("Net.Rest.Api.Server.Controller")

---@class Hosting.Host
local HostExtensions = {}

---@type Dictionary<integer | "all", Net.Rest.Api.Server.Controller>
HostExtensions.ApiControllers = {}

---@param port integer | "all"
---@param endpointLogger Core.Logger
---@param endpointBase Net.Rest.Api.Server.EndpointBase
function HostExtensions:AddEndpointBase(port, endpointLogger, endpointBase)
    local netPort = self._NetworkClient:GetOrCreateNetworkPort(port)
    local apiController = self.ApiControllers[port] or ApiController(netPort, endpointLogger:subLogger("ApiController"))
    apiController:AddEndpointBase(endpointBase)
    netPort:OpenPort()

    self.ApiControllers[port] = apiController
end

return Utils.Class.ExtendClass(HostExtensions, require("Hosting.Host") --{{{@as Hosting.Host}}})
]]
}

return PackageData
