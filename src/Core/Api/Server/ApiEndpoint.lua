local ApiResponseTemplates = require("Core.Api.Server.ApiResponseTemplates")
local StatusCodes = require("Core.Api.StatusCodes")

---@class Core.Api.Server.ApiEndpoint : object
---@field private task Core.Task
---@field private logger Core.Logger
---@overload fun(task: Core.Task, logger: Core.Logger) : Core.Api.Server.ApiEndpoint
local ApiEndpoint = {}

---@private
---@param task Core.Task
---@param logger Core.Logger
function ApiEndpoint:ApiEndpoint(task, logger)
    self.task = task
    self.logger = logger
end

---@param request Core.Api.ApiRequest
---@param context Core.Net.NetworkContext
---@param netClient Core.Net.NetworkClient
function ApiEndpoint:Execute(request, context, netClient)
    self.logger:LogTrace("executing...")
    self.task:Execute(request)
    ---@type Core.Api.ApiResponse
    local response = self.task:GetResults()
    if not self.task:IsSuccess() then
        self.task:LogError(self.logger)
        response = ApiResponseTemplates.InternalServerError(tostring(self.task:GetErrorObject()))
    end
    if context.Header.ReturnPort then
        self.logger:LogTrace("sending response to '" .. context.SenderIPAddress .. "' on port: " .. context.Header.ReturnPort .. "...")
        netClient:SendMessage(context.SenderIPAddress, context.Header.ReturnPort, "Rest-Response", nil, response:ExtractData())
        self.logger:LogTrace("sended response")
    else
        self.logger:LogTrace("sending no response")
    end
    if response.Headers.Message == nil then
        self.logger:LogDebug("request finished with status code: " .. response.Headers.Code)
    else
        self.logger:LogDebug("request finished with status code: ".. response.Headers.Code .." with message: '".. response.Headers.Message .."'")
    end
end

return Utils.Class.CreateClass(ApiEndpoint, "ApiEndpoint")