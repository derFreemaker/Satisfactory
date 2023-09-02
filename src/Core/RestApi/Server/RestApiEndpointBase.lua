local RestApiResponseTemplates = require("Core.RestApi.Server.RestApiResponseTemplates")

---@class Core.RestApi.Server.RestApiEndpointBase : object
---@field protected Templates Core.RestApi.Server.RestApiEndpointBase.RestApiResponseTemplates
local RestApiEndpointBase = {}

---@return fun(self: object, key: any) : key: any, value: any
---@return Core.RestApi.Server.RestApiEndpointBase tbl
---@return any startPoint
function RestApiEndpointBase:__pairs()
    local function iterator(tbl, key)
        local newKey, value = next(tbl, key)
        if type(newKey) == "string" and type(value) == "function" then
            return newKey, value
        end
        return iterator(tbl, newKey)
    end
    return iterator, self, nil
end

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

return Utils.Class.CreateClass(RestApiEndpointBase, "Core.RestApi.Server.RestApiControllerBase")
