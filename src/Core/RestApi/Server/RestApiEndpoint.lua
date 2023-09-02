local RestApiResponseTemplates = require("Core.RestApi.Server.RestApiResponseTemplates")

---@class Core.RestApi.Server.RestApiEndpoint : object
---@field private task Core.Task
---@field private logger Core.Logger
---@overload fun(task: Core.Task, logger: Core.Logger) : Core.RestApi.Server.RestApiEndpoint
local RestApiEndpoint = {}

---@private
---@param task Core.Task
---@param logger Core.Logger
function RestApiEndpoint:RestApiEndpoint(task, logger)
    self.task = task
    self.logger = logger
end

---@param request Core.RestApi.RestApiRequest
---@param context Core.Net.NetworkContext
---@param netClient Core.Net.NetworkClient
function RestApiEndpoint:Execute(request, context, netClient)
    self.logger:LogTrace("executing...")
    self.task:Execute(request)
    ---@type Core.RestApi.RestApiResponse
    local response = self.task:GetResults()
    if not self.task:IsSuccess() then
        self.task:LogError(self.logger)
        response = RestApiResponseTemplates.InternalServerError(tostring(self.task:GetErrorObject()))
    end
    if context.Header.ReturnPort then
        self.logger:LogTrace("sending response to '" .. context.SenderIPAddress .. "' on port: " .. context.Header.ReturnPort .. "...")
        netClient:SendMessage(context.SenderIPAddress, context.Header.ReturnPort, "Rest-Response", nil, response:ExtractData())
    else
        self.logger:LogTrace("sending no response")
    end
    if response.Headers.Message == nil then
        self.logger:LogDebug("request finished with status code: " .. response.Headers.Code)
    else
        self.logger:LogDebug("request finished with status code: " .. response.Headers.Code .. " with message: '" .. response.Headers.Message .. "'")
    end
end

return Utils.Class.CreateClass(RestApiEndpoint, "Core.RestApi.Server.RestApiEndpoint")
