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
