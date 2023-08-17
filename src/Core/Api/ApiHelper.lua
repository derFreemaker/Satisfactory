local ApiRequest = require("Core.Api.ApiRequest")
local ApiResponse = require("Core.Api.ApiResponse")

---@class Core.Api.Helper
local Helper = {}

---@param context Core.Net.NetworkContext
---@return Core.Api.ApiResponse response
function Helper.NetworkContextToApiResponse(context)
    return context.Body
end

---@param context Core.Net.NetworkContext
---@return Core.Api.ApiRequest request
function Helper.NetworkContextToApiRequest(context)
    return context.Body
end

return Helper