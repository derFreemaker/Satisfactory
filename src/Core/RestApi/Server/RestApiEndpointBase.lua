local RestApiResponseTemplates = require("Core.RestApi.Server.RestApiResponseTemplates")

---@class Core.RestApi.Server.RestApiEndpointBase : object
---@field Templates Core.RestApi.Server.RestApiEndpointBase.RestApiResponseTemplates
local RestApiEndpointBase = {}

---@class Core.RestApi.Server.RestApiEndpointBase.RestApiResponseTemplates
RestApiEndpointBase.Templates = {}

---@param value any
---@return Core.RestApi.RestApiResponse
function RestApiEndpointBase.Templates:Ok(value)
    return RestApiResponseTemplates.Ok(value)
end

---@param message string
---@return Core.RestApi.RestApiResponse
function RestApiEndpointBase.Templates:BadRequest(message)
    return RestApiResponseTemplates.BadRequest(message)
end

---@param message string
---@return Core.RestApi.RestApiResponse
function RestApiEndpointBase.Templates:NotFound(message)
    return RestApiResponseTemplates.NotFound(message)
end

---@param message string
---@return Core.RestApi.RestApiResponse
function RestApiEndpointBase.Templates:InternalServerError(message)
    return RestApiResponseTemplates.InternalServerError(message)
end

return Utils.Class.CreateClass(RestApiEndpointBase, "RestApiControllerBase")