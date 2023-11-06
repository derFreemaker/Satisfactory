local Task = require("Core.Common.Task")

local ResponseTemplates = require('Net.Rest.Api.Server.ResponseTemplates')

---@class Net.Rest.Api.Server.EndpointBase : object
---@field protected Logger Core.Logger
---@field protected ApiController Net.Rest.Api.Server.Controller
---@field protected Templates Core.RestNew.Api.Server.EndpointBase.ResponseTemplates
---@overload fun(endpointLogger: Core.Logger, apiController: Net.Rest.Api.Server.Controller) : Net.Rest.Api.Server.EndpointBase
local EndpointBase = {}

---@private
---@param endpointLogger Core.Logger
---@param apiController Net.Rest.Api.Server.Controller
function EndpointBase:__init(endpointLogger, apiController)
	self.Logger = endpointLogger
	self.ApiController = apiController
end

---@param method Net.Core.Method
---@param endpointUrl string
---@param func function
function EndpointBase:AddEndpoint(method, endpointUrl, func)
	self.ApiController:AddEndpoint(method, endpointUrl, Task(func, self))
end

---@class Core.RestNew.Api.Server.EndpointBase.ResponseTemplates
local Templates = {}

---@param value any
---@return Net.Rest.Api.Response
function Templates:Ok(value)
	return ResponseTemplates.Ok(value)
end

---@param message string
---@return Net.Rest.Api.Response
function Templates:BadRequest(message)
	return ResponseTemplates.BadRequest(message)
end

---@param message string
---@return Net.Rest.Api.Response
function Templates:NotFound(message)
	return ResponseTemplates.NotFound(message)
end

---@param message string
---@return Net.Rest.Api.Response
function Templates:InternalServerError(message)
	return ResponseTemplates.InternalServerError(message)
end

EndpointBase.Templates = Templates

return Utils.Class.CreateClass(EndpointBase, 'Net.Rest.Api.Server.EndpointBase')
