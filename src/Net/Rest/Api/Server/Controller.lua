local EventNameUsage = require("Core.Usage_EventName")

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
