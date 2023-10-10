local PackageData = {}

PackageData["NetRestApiExtensions"] = {
    Location = "Net.Rest.Api.Extensions",
    Namespace = "Net.Core.NetworkContext.Api.Extensions",
    IsRunnable = true,
    Data = [[
---@namespace Net.Core.NetworkContext.Api.Extensions

local Request = require('Net.Rest.Api.Request')
local Response = require('Net.Rest.Api.Response')

---@class Net.Rest.Api.Extensions : object
local Extensions = {}

---@param context Net.Core.NetworkContext
---@return Net.Rest.Api.Request
function Extensions:Static_NetworkContextToApiRequest(context)
	return Request(context.Body.Method, context.Body.Endpoint, context.Body.Body, context.Body.Headers)
end

---@param context Net.Core.NetworkContext
---@return Net.Rest.Api.Response
function Extensions:Static_NetworkContextToApiResponse(context)
	return Response(context.Body.Body, context.Body.Headers)
end

return Utils.Class.CreateClass(Extensions, 'Net.Core.NetworkContext.Api.Extensions')
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
local Response = require('Net.Rest.Api.Response')
---@type Net.Rest.Api.Extensions
local Extensions = require('Net.Core.NetworkContext.Api.Extensions')

---@class Net.Rest.Api.Client : object
---@field ServerIPAddress string
---@field ServerPort integer
---@field ReturnPort integer
---@field private NetClient Net.Core.NetworkClient
---@field private logger Core.Logger
---@overload fun(serverIPAddress: string, serverPort: integer, returnPort: integer, netClient: Net.Core.NetworkClient, logger: Core.Logger) : Net.Rest.Api.Client
local Client = {}

---@private
---@param serverIPAddress string
---@param serverPort integer
---@param returnPort integer
---@param netClient Net.Core.NetworkClient
---@param logger Core.Logger
function Client:__init(serverIPAddress, serverPort, returnPort, netClient, logger)
	self.ServerIPAddress = serverIPAddress
	self.ServerPort = serverPort
	self.ReturnPort = returnPort
	self.NetClient = netClient
	self.logger = logger
end

---@param request Net.Rest.Api.Request
---@param timeout integer?
---@return Net.Rest.Api.Response response
function Client:Send(request, timeout)
	self.NetClient:Send(self.ServerIPAddress, self.ServerPort, 'Rest-Request', request:ExtractData(), {ReturnPort = self.ReturnPort})
	local context = self.NetClient:WaitForEvent('Rest-Response', self.ReturnPort, timeout or 5)
	if not context then
		return Response(nil, {Code = 408})
	end

	local response = Extensions:Static_NetworkContextToApiResponse(context)
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
local Task = require('Core.Task')
local RestApiEndpoint = require('Net.Rest.Api.Server.Endpoint')
local RestApiResponseTemplates = require('Net.Rest.Api.Server.ResponseTemplates')
local RestApiMethod = require('Net.Core.Method')
---@type Net.Rest.Api.Extensions
local Extensions = require('Net.Core.NetworkContext.Api.Extensions')

---@class Net.Rest.Api.Server.Controller : object
---@field Endpoints Dictionary<string, Net.Rest.Api.Server.Endpoint>
---@field private netPort Net.Core.NetworkPort
---@field private logger Core.Logger
---@overload fun(netPort: Net.Core.NetworkPort, logger: Core.Logger) : Net.Rest.Api.Server.Controller
local Controller = {}

---@private
---@param netPort Net.Core.NetworkPort
---@param logger Core.Logger
function Controller:__init(netPort, logger)
	self.Endpoints = {}
	self.netPort = netPort
	self.logger = logger
	netPort:AddListener('Rest-Request', Task(self.onMessageRecieved, self))
end

---@private
---@param context Net.Core.NetworkContext
function Controller:onMessageRecieved(context)
	local request = Extensions:Static_NetworkContextToApiRequest(context)
	self.logger:LogDebug("recieved request on endpoint: '" .. request.Endpoint .. "'")
	local endpoint = self:GetEndpoint(request.Method, request.Endpoint)
	if endpoint == nil then
		self.logger:LogTrace('found no endpoint')
		if context.Header.ReturnPort then
			self.netPort:GetNetClient():Send(context.SenderIPAddress, context.Header.ReturnPort, 'Rest-Response', RestApiResponseTemplates.NotFound('Unable to find endpoint'):ExtractData())
		end
		return
	end
	self.logger:LogTrace('found endpoint: ' .. request.Endpoint)
	endpoint:Execute(request, context, self.netPort:GetNetClient())
end

---@param method Net.Core.Method
---@param endpointName string
---@return Net.Rest.Api.Server.Endpoint?
function Controller:GetEndpoint(method, endpointName)
	for name, endpoint in pairs(self.Endpoints) do
		if name == method .. '__' .. endpointName then
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
	local endpointName = method .. '__' .. name
	self.Endpoints[endpointName] = RestApiEndpoint(task, self.logger:subLogger('RestApiEndpoint[' .. endpointName .. ']'))
	self.logger:LogTrace("Added endpoint: '" .. method .. "' -> '" .. name .. "'")
	return self
end

---@param endpoint Net.Rest.Api.Server.EndpointBase
function Controller:AddRestApiEndpointBase(endpoint)
	for name, func in pairs(endpoint) do
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
local RestApiResponseTemplates = require('Net.Rest.Api.Server.ResponseTemplates')

---@class Net.Rest.Api.Server.Endpoint : object
---@field private task Core.Task
---@field private logger Core.Logger
---@overload fun(task: Core.Task, logger: Core.Logger) : Net.Rest.Api.Server.Endpoint
local Endpoint = {}

---@private
---@param task Core.Task
---@param logger Core.Logger
function Endpoint:__init(task, logger)
	self.task = task
	self.logger = logger
end

---@param request Net.Rest.Api.Request
---@param context Net.Core.NetworkContext
---@param netClient Net.Core.NetworkClient
function Endpoint:Execute(request, context, netClient)
	self.logger:LogTrace('executing...')
	___logger:setLogger(self.logger)
	self.task:Execute(request)
	self.task:LogError(self.logger)
	___logger:revert()
	---@type Net.Rest.Api.Response
	local response = self.task:GetResults()
	if not self.task:IsSuccess() then
		response = RestApiResponseTemplates.InternalServerError(tostring(self.task:GetTraceback()))
	end
	if context.Header.ReturnPort then
		self.logger:LogTrace("sending response to '" .. context.SenderIPAddress .. "' on port: " .. context.Header.ReturnPort .. '...')
		netClient:Send(context.SenderIPAddress, context.Header.ReturnPort, 'Rest-Response', response:ExtractData())
	else
		self.logger:LogTrace('sending no response')
	end
	if response.Headers.Message == nil then
		self.logger:LogDebug('request finished with status code: ' .. response.Headers.Code)
	else
		self.logger:LogDebug('request finished with status code: ' .. response.Headers.Code .. " with message: '" .. response.Headers.Message .. "'")
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

---@return fun(self: object, key: any) : key: any, value: any
---@return Net.Rest.Api.Server.EndpointBase tbl
---@return any startPoint
function EndpointBase:__pairs()
	local function iterator(tbl, key)
		local newKey,
			value = next(tbl, key)
		if type(newKey) == 'string' and type(value) == 'function' then
			return newKey, value
		end
		if newKey == nil and value == nil then
			return nil, nil
		end
		return iterator(tbl, newKey)
	end
	return iterator, self, nil
end

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
	return RestApiResponse(value, {Code = StatusCodes.Status200OK})
end

---@param message string
---@return Net.Rest.Api.Response
function ResponseTemplates.BadRequest(message)
	return RestApiResponse(nil, {Code = StatusCodes.Status400BadRequest, Message = message})
end

---@param message string
---@return Net.Rest.Api.Response
function ResponseTemplates.NotFound(message)
	return RestApiResponse(nil, {Code = StatusCodes.Status404NotFound, Message = message})
end

---@param message string
---@return Net.Rest.Api.Response
function ResponseTemplates.InternalServerError(message)
	return RestApiResponse(nil, {Code = StatusCodes.Status500InternalServerError, Message = message})
end

return ResponseTemplates
]]
}

return PackageData
