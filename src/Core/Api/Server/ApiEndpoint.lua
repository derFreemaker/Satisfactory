local ApiResponseTemplates = require("Core.Api.Server.ApiResponseTemplates")

---@class Core.Api.Server.ApiEndpoint : object
---@field private listener Core.Listener
---@overload fun(listener: Core.Listener) : Core.Api.Server.ApiEndpoint
local ApiEndpoint = {}

---@private
---@param listener Core.Listener
function ApiEndpoint:ApiEndpoint(listener)
    self.listener = listener
end

---@param request Core.Api.ApiRequest
---@return Core.Api.ApiResponse response
function ApiEndpoint:Execute(request)
    local success, response = self.listener:ExecuteDynamic({ request })
    if not success then
        return ApiResponseTemplates.InternalServerError(response[1])
    end
    return response
end

return Utils.Class.CreateClass(ApiEndpoint, "ApiEndpoint")