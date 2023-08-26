local ApiResponseTemplates = require("Core.Api.Server.ApiResponseTemplates")

---@class Core.Api.Server.ApiEndpoint : object
---@field private task Core.Task
---@overload fun(task: Core.Task) : Core.Api.Server.ApiEndpoint
local ApiEndpoint = {}

---@private
---@param task Core.Task
function ApiEndpoint:ApiEndpoint(task)
    self.task = task
end

---@param logger Core.Logger?
---@param request Core.Api.ApiRequest
---@return Core.Api.ApiResponse response
function ApiEndpoint:Execute(logger, request)
    self.task:Execute(request)
    local response = self.task:GetResults()
    if not self.task:IsSuccess() then
        self.task:LogError(logger)
        return ApiResponseTemplates.InternalServerError(tostring(self.task:GetErrorObject()))
    end
    return response
end

return Utils.Class.CreateClass(ApiEndpoint, "ApiEndpoint")