local StatusCodes = require("Core.RestApi.StatusCodes")
local RestApiResponse = require("Core.RestApi.RestApiResponse")

---@class Net.Rest.Api.Server.RestApiResponseTemplates
local ResponseTemplates = {}

---@param value any
---@return Net.Rest.Api.Response
function ResponseTemplates.Ok(value)
    return RestApiResponse(value, { Code = StatusCodes.Status200OK })
end

---@param message string
---@return Net.Rest.Api.Response
function ResponseTemplates.BadRequest(message)
    return RestApiResponse(nil, { Code = StatusCodes.Status400BadRequest, Message = message })
end

---@param message string
---@return Net.Rest.Api.Response
function ResponseTemplates.NotFound(message)
    return RestApiResponse(nil, { Code = StatusCodes.Status404NotFound, Message = message })
end

---@param message string
---@return Net.Rest.Api.Response
function ResponseTemplates.InternalServerError(message)
    return RestApiResponse(nil, { Code = StatusCodes.Status500InternalServerError, Message = message })
end

return ResponseTemplates