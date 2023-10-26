local Uri = require("Net.Rest.Uri")

local FactoryControlConfig = require("FactoryControl.Core.Config")
local HttpClient = require('Net.Http.Client')
local HttpRequest = require('Net.Http.Request')

---@class FactoryControl.Client.DataClient : object
---@field private m_client Net.Http.Client
---@field private m_logger Core.Logger
---@overload fun(logger: Core.Logger) : FactoryControl.Client.DataClient
local DataClient = {}

---@private
---@param logger Core.Logger
function DataClient:__init(logger)
	self.m_logger = logger
	self.m_client = HttpClient(self.m_logger:subLogger('RestApiClient'))
end

---@private
---@param method Net.Core.Method
---@param endpoint string
---@param body any
---@param options Net.Http.Request.Options?
---@return Net.Http.Response response
function DataClient:request(method, endpoint, body, options)
	local request = HttpRequest(method, FactoryControlConfig.DOMAIN, Uri.Static__Parse(endpoint), body, options)
	return self.m_client:Send(request)
end

---@param name string
---@param ipAddress Net.Core.IPAddress
---@return FactoryControl.Core.Entities.ControllerDto?
function DataClient:Connect(name, ipAddress)
	local response = self:request("CONNECT", "Controller", { name, ipAddress })

	if response:IsFaulted() then
		return
	end

	return response:GetBody()
end

---@param createController FactoryControl.Core.Entities.Controller.CreateDto
---@return FactoryControl.Core.Entities.ControllerDto?
function DataClient:CreateController(createController)
	local response = self:request('CREATE', 'Controller', createController)

	if response:IsFaulted() then
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
---@param modifyController FactoryControl.Core.Entities.Controller.ModifyDto
---@return FactoryControl.Core.Entities.ControllerDto?
function DataClient:ModifyControllerById(id, modifyController)
	local response = self:request("POST", "ModifyControllerById", { id, modifyController })

	if response:IsFaulted() then
		return
	end

	return response:GetBody()
end

---@param id Core.UUID
---@return FactoryControl.Core.Entities.ControllerDto?
function DataClient:GetControllerById(id)
	local response = self:request("GET", "ControllerById", id)

	if response:IsFaulted() then
		return
	end

	return response:GetBody()
end

---@param name string
---@return FactoryControl.Core.Entities.ControllerDto?
function DataClient:GetControllerByName(name)
	local response = self:request("GET", "ControllerByName", name)

	if response:IsFaulted() then
		return
	end

	return response:GetBody()
end

return Utils.Class.CreateClass(DataClient, "FactoryControl.Client.DataClient")
