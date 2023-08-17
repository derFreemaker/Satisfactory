local StatusCodes = require("Core.Api.StatusCodes")
local ApiResponse = require("Core.Api.ApiResponse")

---@class Core.Api.Server.ApiResponseTemplates
local ApiResponseTemplates = {}

---@param value any
---@return Core.Api.ApiResponse
function ApiResponseTemplates.Ok(value)
    return ApiResponse({ Code = StatusCodes.Status200OK }, value)
end

---@param message string
---@return Core.Api.ApiResponse
function ApiResponseTemplates.BadRequest(message)
    return ApiResponse({ Code = StatusCodes.Status400BadRequest, Message = message })
end

---@param message string
---@return Core.Api.ApiResponse
function ApiResponseTemplates.NotFound(message)
    return ApiResponse({ Code = StatusCodes.Status404NotFound, Message = message })
end

---@param message string
---@return Core.Api.ApiResponse
function ApiResponseTemplates.InternalServerError(message)
    return ApiResponse({ Code = StatusCodes.Status500InternalServerError, Message = message })
end

return ApiResponseTemplates