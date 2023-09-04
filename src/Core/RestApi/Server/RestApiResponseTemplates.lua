local StatusCodes = require("Core.RestApi.StatusCodes")
local RestApiResponse = require("Core.RestApi.RestApiResponse")

---@class Core.RestApi.Server.RestApiResponseTemplates
local RestApiResponseTemplates = {}

---@param value any
---@return Core.RestApi.RestApiResponse
function RestApiResponseTemplates.Ok(value)
    return RestApiResponse({ Code = StatusCodes.Status200OK }, value)
end

---@param message string
---@return Core.RestApi.RestApiResponse
function RestApiResponseTemplates.BadRequest(message)
    return RestApiResponse({ Code = StatusCodes.Status400BadRequest, Message = message })
end

---@param message string
---@return Core.RestApi.RestApiResponse
function RestApiResponseTemplates.NotFound(message)
    return RestApiResponse({ Code = StatusCodes.Status404NotFound, Message = message })
end

---@param message string
---@return Core.RestApi.RestApiResponse
function RestApiResponseTemplates.InternalServerError(message)
    return RestApiResponse({ Code = StatusCodes.Status500InternalServerError, Message = message })
end

return RestApiResponseTemplates