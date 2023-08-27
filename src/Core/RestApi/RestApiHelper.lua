local RestApiRequest = require("Core.RestApi.RestApiRequest")
local RestApiResponse = require("Core.RestApi.RestApiResponse")

---@class Core.RestApi.Helper
local Helper = {}

---@param context Core.Net.NetworkContext
---@return Core.RestApi.RestApiResponse response
function Helper.NetworkContextToRestApiResponse(context)
    return RestApiResponse(context.Body.Headers, context.Body.Body)
end

---@param context Core.Net.NetworkContext
---@return Core.RestApi.RestApiRequest request
function Helper.NetworkContextToRestApiRequest(context)
    return RestApiRequest(context.Body.Method, context.Body.Endpoint, context.Body.Headers, context.Body.Body)
end

return Helper