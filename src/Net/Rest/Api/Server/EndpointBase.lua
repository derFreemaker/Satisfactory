local RestApiResponseTemplates = require("Core.RestApi.Server.RestApiResponseTemplates")

---@class Net.Rest.Api.Server.EndpointBase : object
---@field protected Templates Core.RestApi.Server.RestApiEndpointBase.RestApiResponseTemplates
local EndpointBase = {}

---@return fun(self: object, key: any) : key: any, value: any
---@return Net.Rest.Api.Server.EndpointBase tbl
---@return any startPoint
function EndpointBase:__pairs()
    local function iterator(tbl, key)
        local newKey, value = next(tbl, key)
        if type(newKey) == "string" and type(value) == "function" then
            return newKey, value
        end
        if newKey == nil and value == nil then
            return nil, nil
        end
        return iterator(tbl, newKey)
    end
    return iterator, self, nil
end

---@class Core.RestApi.Server.RestApiEndpointBase.RestApiResponseTemplates
EndpointBase.Templates = {}

---@param value any
---@return Net.Rest.Api.Response
function EndpointBase.Templates:Ok(value)
    return RestApiResponseTemplates.Ok(value)
end

---@param message string
---@return Net.Rest.Api.Response
function EndpointBase.Templates:BadRequest(message)
    return RestApiResponseTemplates.BadRequest(message)
end

---@param message string
---@return Net.Rest.Api.Response
function EndpointBase.Templates:NotFound(message)
    return RestApiResponseTemplates.NotFound(message)
end

---@param message string
---@return Net.Rest.Api.Response
function EndpointBase.Templates:InternalServerError(message)
    return RestApiResponseTemplates.InternalServerError(message)
end

return Utils.Class.CreateClass(EndpointBase, "Net.Rest.Api.Server.EndpointBase")
