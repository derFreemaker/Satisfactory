local EventNameUsage    = require("Core.Usage.Usage_EventName")
local StatusCodes       = require("Net.Core.StatusCodes")

local ResponseTemplates = require('Net.Rest.Api.Server.ResponseTemplates')

local UUID              = require("Core.UUID")

---@class Net.Rest.Api.Server.Endpoint : object
---@field private m_endpointUriPattern string
---@field private m_endpointUriTemplate string
---@field private m_parameterTypes string[]
---@field private m_task Core.Task
---@field private m_logger Core.Logger
---@overload fun(endpointUriPattern: string, task: Core.Task, logger: Core.Logger) : Net.Rest.Api.Server.Endpoint
local Endpoint          = {}

---@private
---@param endpointUriPattern string
---@param task Core.Task
---@param logger Core.Logger
function Endpoint:__init(endpointUriPattern, task, logger)
    self.m_endpointUriPattern = endpointUriPattern
    self.m_endpointUriTemplate = endpointUriPattern:gsub("{[a-zA-Z0-9]*:[a-zA-Z0-9\\.]*}", "(.+)")

    self.m_parameterTypes = {}
    for parameterType in endpointUriPattern:gmatch("{[a-zA-Z0-9]*:([a-zA-Z0-9\\.]*)}") do
        table.insert(self.m_parameterTypes, parameterType)
    end

    self.m_task = task
    self.m_logger = logger
end

---@private
---@param uri string
---@return any[] parameters
function Endpoint:GetUriParameters(uri)
    local parameters = { uri:match(self.m_endpointUriTemplate) }

    local parameterTypes = self.m_parameterTypes
    for i = 1, #parameters, 1 do
        local parameterType = parameterTypes[i]
        local parameter = parameters[i]

        if parameterType == "boolean" then
            parameters[i] = parameter == "true"
        elseif parameterType == "string" then
        elseif parameterType == "number" then
            parameters[i] = tonumber(parameter)
        elseif parameterType == "integer" then
            local number = tonumber(parameter)
            if number then
                parameters[i] = math.floor(number)
            end
        elseif parameterType == "Core.UUID" then
            parameters[i] = UUID.Static__Parse(parameter)
        else
            error("unkown parameter type: '" .. parameterType .. "'")
        end
    end

    return parameters
end

---@private
---@param uri string
---@return any[] parameters, string? parseError
function Endpoint:ParseUriParameters(uri)
    local success, errorMsg, returns = Utils.Function.InvokeProtected(self.GetUriParameters, self, uri)
    return returns[1] or {}, errorMsg
end

---@private
---@param uriParameters any[]
---@param request Net.Rest.Api.Request
---@param context Net.Core.NetworkContext
---@return Net.Rest.Api.Response response
function Endpoint:Execute(uriParameters, request, context)
    local response
    if #uriParameters == 0 then
        response = self.m_task:Execute(request.Body, request, context)
    else
        response = self.m_task:Execute(table.unpack(uriParameters), request.Body, request, context)
    end
    self.m_task:Close()

    if not self.m_task:IsSuccess() then
        self.m_logger:LogError("endpoint failed with error:", self.m_task:GetTraceback())
        response = ResponseTemplates.InternalServerError(self.m_task:GetTraceback() or "no error")
    end

    return response
end

---@param request Net.Rest.Api.Request
---@param context Net.Core.NetworkContext
---@return Net.Rest.Api.Response response
function Endpoint:Invoke(request, context)
    self.m_logger:LogTrace('executing...')
    ___logger:setLogger(self.m_logger)

    local response
    local uriParameters, parseError = self:ParseUriParameters(tostring(request.Endpoint))
    if parseError then
        response = ResponseTemplates.InternalServerError(parseError or "uri parameters could not be parsed")
        return response
    end

    response = self:Execute(uriParameters, request, context)
    self.m_logger:LogDebug('request finished with status code: ' .. response.Headers.Code)

    return response
end

return Utils.Class.CreateClass(Endpoint, "Net.Rest.Api.Server.Endpoint")
