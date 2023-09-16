local RestApiResponseTemplates = require("Net.Rest.Api.Server.ResponseTemplates")

---@class Net.Rest.Api.Server.Endpoint : object
---@field private task Core.Task
---@field private logger Core.Logger
---@overload fun(task: Core.Task, logger: Core.Logger) : Net.Rest.Api.Server.Endpoint
local Endpoint = {}

---@private
---@param task Core.Task
---@param logger Core.Logger
function Endpoint:__init(task, logger)
    self.task = task
    self.logger = logger
end

---@param request Net.Rest.Api.Request
---@param context Core.Net.NetworkContext
---@param netClient Core.Net.NetworkClient
function Endpoint:Execute(request, context, netClient)
    self.logger:LogTrace("executing...")
    ___logger:setLogger(self.logger)
    self.task:Execute(request)
    self.task:LogError(self.logger)
    ___logger:revert()
    ---@type Net.Rest.Api.Response
    local response = self.task:GetResults()
    if not self.task:IsSuccess() then
        response = RestApiResponseTemplates.InternalServerError(tostring(self.task:GetTraceback()))
    end
    if context.Header.ReturnPort then
        self.logger:LogTrace("sending response to '" ..
        context.SenderIPAddress .. "' on port: " .. context.Header.ReturnPort .. "...")
        netClient:SendMessage(context.SenderIPAddress, context.Header.ReturnPort, "Rest-Response", response:ExtractData())
    else
        self.logger:LogTrace("sending no response")
    end
    if response.Headers.Message == nil then
        self.logger:LogDebug("request finished with status code: " .. response.Headers.Code)
    else
        self.logger:LogDebug("request finished with status code: " ..
        response.Headers.Code .. " with message: '" .. response.Headers.Message .. "'")
    end
end

return Utils.Class.CreateClass(Endpoint, "Net.Rest.Api.Server.Endpoint")
