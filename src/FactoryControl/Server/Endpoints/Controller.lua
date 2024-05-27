local ControllerUrlTemplates = require("FactoryControl.Core.EndpointUrls")[1].Controller

---@class FactoryControl.Server.Endpoints.Controller : Net.Rest.Api.Server.EndpointBase
---@field private m_databaseAccessLayer FactoryControl.Server.DatabaseAccessLayer
---@field private m_logger Core.Logger
---@overload fun(logger: Core.Logger, apiController: Net.Rest.Api.Server.Controller, databaseAccessLayer: FactoryControl.Server.DatabaseAccessLayer) : FactoryControl.Server.Endpoints.Controller
local ControllerEndpoints = {}

---@private
---@param logger Core.Logger
---@param apiController Net.Rest.Api.Server.Controller
---@param databaseAccessLayer FactoryControl.Server.DatabaseAccessLayer
---@param super fun(endpointLogger: Core.Logger, apiController: Net.Rest.Api.Server.Controller)
function ControllerEndpoints:__init(super, logger, apiController, databaseAccessLayer)
	super(logger, apiController)

	self.m_databaseAccessLayer = databaseAccessLayer

	self:AddEndpoint("CONNECT", ControllerUrlTemplates.Connect, self.Connect)

	self:AddEndpoint("CREATE", ControllerUrlTemplates.Create, self.Create)
	self:AddEndpoint("DELETE", ControllerUrlTemplates.Delete, self.Delete)
	self:AddEndpoint("POST", ControllerUrlTemplates.Modify, self.Modify)
	self:AddEndpoint("GET", ControllerUrlTemplates.GetById, self.GetById)
	self:AddEndpoint("GET", ControllerUrlTemplates.GetByName, self.GetByName)
end

---@param connect FactoryControl.Core.Entities.Controller.ConnectDto
---@return Net.Rest.Api.Response response
function ControllerEndpoints:Connect(connect)
	local controller = self.m_databaseAccessLayer:GetControllerByName(connect.Name)
	if not controller then
		return self.Templates:NotFound("Controller with Name: " .. connect.Name .. " was not found.")
	end

	if controller.IPAddress ~= connect.IPAddress then
		controller.IPAddress = connect.IPAddress
	end

	return self.Templates:Ok(controller)
end

---@param createController FactoryControl.Core.Entities.Controller.CreateDto
---@return Net.Rest.Api.Response response
function ControllerEndpoints:Create(createController)
	local controller = self.m_databaseAccessLayer:CreateController(createController)

	if not controller then
		return self.Templates:BadRequest("Controller with Name: " .. createController.Name .. " already exists.")
	end

	return self.Templates:Ok(controller)
end

---@param id Core.UUID
---@return Net.Rest.Api.Response response
function ControllerEndpoints:Delete(id)
	self.m_databaseAccessLayer:DeleteController(id)

	return self.Templates:Ok(true)
end

---@param id Core.UUID
---@param modifyController FactoryControl.Core.Entities.Controller.ModifyDto
---@return Net.Rest.Api.Response response
function ControllerEndpoints:Modify(id, modifyController)
	local controller = self.m_databaseAccessLayer:GetControllerById(id)

	if not controller then
		return self.Templates:NotFound("Controller with id: " .. tostring(id) .. " was not found.")
	end

	controller.Features = modifyController.Features

	return self.Templates:Ok(controller)
end

---@param id Core.UUID
---@return Net.Rest.Api.Response response
function ControllerEndpoints:GetById(id)
	local controller = self.m_databaseAccessLayer:GetControllerById(id)

	if not controller then
		return self.Templates:NotFound("Controller with id: " .. tostring(id) .. " was not found.")
	end

	return self.Templates:Ok(controller)
end

---@param name string
---@return Net.Rest.Api.Response response
function ControllerEndpoints:GetByName(name)
	local controller = self.m_databaseAccessLayer:GetControllerByName(name)

	if not controller then
		return self.Templates:NotFound("Controller with name: " .. name .. " was not found.")
	end

	return self.Templates:Ok(controller)
end

return class("FactoryControl.Server.Endpoints.Controller", ControllerEndpoints,
	{ Inherit = require("Net.Rest.Api.Server.EndpointBase") })
