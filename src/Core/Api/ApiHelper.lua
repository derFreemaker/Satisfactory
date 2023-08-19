local ApiRequest = require("Core.Api.ApiRequest")
local ApiResponse = require("Core.Api.ApiResponse")

---@class Core.Api.Helper
local Helper = {}

---@param context Core.Net.NetworkContext
---@return Core.Api.ApiResponse response
function Helper.NetworkContextToApiResponse(context)
    return ApiResponse(context.Body.Headers, context.Body.Body)
end

---@param context Core.Net.NetworkContext
---@return Core.Api.ApiRequest request
function Helper.NetworkContextToApiRequest(context)
    return ApiRequest(context.Body.Endpoint, context.Body.Headers, context.Body.Body)
end

return Helper