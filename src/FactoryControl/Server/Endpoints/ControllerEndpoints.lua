local Controllers = require("FactoryControl.Server.Database.Controllers")

---@class FactoryControl.Server.Endpoints.ControllerEndpoints : Net.Rest.Api.Server.EndpointBase
---@field private _Controllers FactoryControl.Server.Database.Controllers
---@field private _Logger Core.Logger
---@overload fun(logger: Core.Logger) : FactoryControl.Server.Endpoints.ControllerEndpoints
local ControllerEndpoints = {}

---@private
---@param logger Core.Logger
function ControllerEndpoints:__init(logger)
	self._Controllers = Controllers(logger:subLogger("Database"))
	self._Logger = logger
end

---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function ControllerEndpoints:CREATE__Controller(request)
	---@type FactoryControl.Core.Entities.Controller.CreateDto
	local createController = request.Body

	local controller = self._Controllers:CreateController(createController)

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
function ControllerEndpoints:GET__ControllerById(request)
	---@type Core.UUID
	local id = request.Body

	local controller = self._Controllers:GetController(id)

	if not controller then
		return self.Templates:NotFound("Controller with id: " .. tostring(id))
	end

	return self.Templates:Ok(controller)
end

-- get controller with name

return Utils.Class.CreateClass(ControllerEndpoints, 'FactoryControl.Server.ControllerEndpoints',
	require('Net.Rest.Api.Server.EndpointBase'))
