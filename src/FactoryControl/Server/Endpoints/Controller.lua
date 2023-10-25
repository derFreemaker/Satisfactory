---@class FactoryControl.Server.Endpoints.ControllerEndpoints : Net.Rest.Api.Server.EndpointBase
---@field private _Controllers FactoryControl.Server.Database.Controllers
---@field private _Logger Core.Logger
---@overload fun(logger: Core.Logger, apiController: Net.Rest.Api.Server.Controller, databaseAccessLayer: FactoryControl.Server.Database.Controllers) : FactoryControl.Server.Endpoints.ControllerEndpoints
local ControllerEndpoints = {}

---@private
---@param logger Core.Logger
---@param apiController Net.Rest.Api.Server.Controller
---@param databaseAccessLayer FactoryControl.Server.Database.Controllers
---@param baseFunc fun(endpointLogger: Core.Logger, apiController: Net.Rest.Api.Server.Controller)
function ControllerEndpoints:__init(baseFunc, logger, apiController, databaseAccessLayer)
	baseFunc(logger, apiController)

	self._Controllers = databaseAccessLayer

	self:AddEndpoint("CONNECT", "/Controller/Connect", self.Connect)

	self:AddEndpoint("CREATE", "/Controller/Create", self.Create)
	self:AddEndpoint("DELETE", "/Controller/{id:Core.UUID}/Delete", self.DeleteWithId)
	self:AddEndpoint("POST", "/Controller/{id:Core.UUID}/Modify", self.ModifyWithId)
	self:AddEndpoint("GET", "/Controller/{id:Core.UUID}", self.GetWithId)
	self:AddEndpoint("GET", "/Controller/GetWithName", self.GetWithName)
end

---@param connect FactoryControl.Core.Entities.Controller.ConnectDto
---@return Net.Rest.Api.Response response
function ControllerEndpoints:Connect(connect)
	local controller = self._Controllers:GetControllerByName(connect.Name)
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
	local controller = self._Controllers:CreateController(createController)

	if not controller then
		return self.Templates:BadRequest("Controller with Name: " .. createController.Name .. " already exists.")
	end

	return self.Templates:Ok(controller)
end

---@param id Core.UUID
---@return Net.Rest.Api.Response response
function ControllerEndpoints:DeleteWithId(id)
	self._Controllers:DeleteController(id)

	return self.Templates:Ok(true)
end

---@param id Core.UUID
---@param modifyController FactoryControl.Core.Entities.Controller.ModifyDto
---@return Net.Rest.Api.Response response
function ControllerEndpoints:ModifyWithId(id, modifyController)
	local controller = self._Controllers:GetControllerById(id)

	if not controller then
		return self.Templates:NotFound("Controller with id: " .. tostring(id) .. " was not found.")
	end

	controller.Features = modifyController.Features

	return self.Templates:Ok(controller)
end

---@param id Core.UUID
---@return Net.Rest.Api.Response response
function ControllerEndpoints:GetWithId(id)
	local controller = self._Controllers:GetControllerById(id)

	if not controller then
		return self.Templates:NotFound("Controller with id: " .. tostring(id) .. " was not found.")
	end

	return self.Templates:Ok(controller)
end

---@param name string
---@return Net.Rest.Api.Response response
function ControllerEndpoints:GetWithName(name)
	local controller = self._Controllers:GetControllerByName(name)

	if not controller then
		return self.Templates:NotFound("Controller with name: " .. name .. " was not found.")
	end

	return self.Templates:Ok(controller)
end

return Utils.Class.CreateClass(ControllerEndpoints, 'FactoryControl.Server.ControllerEndpoints',
	require('Net.Rest.Api.Server.EndpointBase') --[[@as Net.Rest.Api.Server.EndpointBase]])
