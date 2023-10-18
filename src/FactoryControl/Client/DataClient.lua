local FactoryControlConfig = require("FactoryControl.Core.Config")
local HttpClient = require('Net.Http.Client')
local HttpRequest = require('Net.Http.Request')

---@class FactoryControl.Client.DataClient : object
---@field private _Client Net.Http.Client
---@field private _Logger Core.Logger
---@overload fun(logger: Core.Logger) : FactoryControl.Client.DataClient
local DataClient = {}

---@private
---@param logger Core.Logger
function DataClient:__init(netClient, logger)
	self._Logger = logger
	self._Client = HttpClient(self._Logger:subLogger('RestApiClient'))
end

---@private
---@param method Net.Core.Method
---@param endpoint string
---@param body any
---@param options Net.Http.Request.Options?
---@return Net.Http.Response response
function DataClient:request(method, endpoint, body, options)
	local request = HttpRequest(method, endpoint, FactoryControlConfig.DOMAIN, body, options)
	return self._Client:Send(request)
end

---@param createController FactoryControl.Core.Entities.Controller.CreateDto
---@return FactoryControl.Core.Entities.Controller.ControllerDto?
function DataClient:CreateController(createController)
	local response = self:request('CREATE', 'Controller', createController)

	if not response:IsFaulted() then
		return
	end

	return response:GetBody()
end

---@param id Core.UUID
---@return boolean success
function DataClient:DeleteControllerById(id)
	local response = self:request("DELETE", "ControllerById", id)

	return response:IsSuccess() and response:GetBody()
end

---@param id Core.UUID
---@return FactoryControl.Core.Entities.Controller.ControllerDto?
function DataClient:GetControllerById(id)
	local response = self:request("GET", "ControllerById", id)

	if not response:IsFaulted() then
		return
	end

	return response:GetBody()
end

return Utils.Class.CreateClass(DataClient, "FactoryControl.Client.DataClient")
