---@class FactoryControl.Server.Endpoints.ControllerEndpoints : Net.Rest.Api.Server.EndpointBase
---@field private _Controllers FactoryControl.Server.Database.Controllers
---@field private _Logger Core.Logger
---@overload fun(logger: Core.Logger, databaseAccessLayer: FactoryControl.Server.Database.Controllers) : FactoryControl.Server.Endpoints.ControllerEndpoints
local ControllerEndpoints = {}

---@private
---@param logger Core.Logger
---@param databaseAccessLayer FactoryControl.Server.Database.Controllers
function ControllerEndpoints:__init(logger, databaseAccessLayer)
	self._Controllers = databaseAccessLayer
	self._Logger = logger
end

---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function ControllerEndpoints:CONNECT__Controller(request)
	---@type string, Net.Core.IPAddress
	local name, ipAddress = request.Body[1], request.Body[2]

	local controller = self._Controllers:GetControllerByName(name)
	if not controller then
		return self.Templates:NotFound("Controller with Name: " .. name .. " was not found.")
	end

	controller.IPAddress = ipAddress

	return self.Templates:Ok(controller)
end

---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function ControllerEndpoints:CREATE__Controller(request)
	---@type FactoryControl.Core.Entities.Controller.CreateDto
	local createController = request.Body

	local controller = self._Controllers:CreateController(createController)

	if not controller then
		return self.Templates:BadRequest("Controller with Name: " .. createController.Name .. " already exists.")
	end

	return self.Templates:Ok(controller)
end

---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function ControllerEndpoints:DELETE__ControllerById(request)
	---@type Core.UUID
	local id = request.Body

	self._Controllers:DeleteController(id)

	return self.Templates:Ok()
end

---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function ControllerEndpoints:POST__ModifyControllerById(request)
	---@type Core.UUID, FactoryControl.Core.Entities.Controller.ModifyDto
	local id, modifyController = request.Body[1], request.Body[2]

	local controller = self._Controllers:GetControllerById(id)

	if not controller then
		return self.Templates:NotFound("Controller with id: " .. tostring(id) .. " was not found.")
	end

	controller.Features = modifyController.Features

	return self.Templates:Ok(controller)
end

---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function ControllerEndpoints:GET__ControllerById(request)
	---@type Core.UUID
	local id = request.Body

	local controller = self._Controllers:GetControllerById(id)

	if not controller then
		return self.Templates:NotFound("Controller with id: " .. tostring(id))
	end

	return self.Templates:Ok(controller)
end

---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function ControllerEndpoints:GET__ControllerByName(request)
	---@type string
	local name = request.Body

	local controller = self._Controllers:GetControllerByName(name)

	if not controller then
		return self.Templates:NotFound("Controller with id: " .. name)
	end

	return self.Templates:Ok(controller)
end

return Utils.Class.CreateClass(ControllerEndpoints, 'FactoryControl.Server.ControllerEndpoints',
	require('Net.Rest.Api.Server.EndpointBase'))
