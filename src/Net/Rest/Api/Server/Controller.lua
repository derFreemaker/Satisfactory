local EventNameUsage = require("Core.Usage.Usage_EventName")

local Task = require("Core.Common.Task")

local Endpoint = require("Net.Rest.Api.Server.Endpoint")

local ResponseTemplates = require("Net.Rest.Api.Server.ResponseTemplates")

---@class Net.Rest.Api.Server.Controller : object
---@field private m_endpoints table<Net.Core.Method, table<string, Net.Rest.Api.Server.Endpoint>>
---@field private m_netPort Net.Core.NetworkPort
---@field private m_logger Core.Logger
---@overload fun(netPort: Net.Core.NetworkPort, logger: Core.Logger) : Net.Rest.Api.Server.Controller
local Controller = {}

---@private
---@param netPort Net.Core.NetworkPort
---@param logger Core.Logger
function Controller:__init(netPort, logger)
    self.m_endpoints = {}
    self.m_netPort = netPort
    self.m_logger = logger

    netPort:AddTask(
        EventNameUsage.RestRequest,
        Task(function(...)
            self:onMessageReceived(...)
        end)
    )
end

---@private
---@param context Net.Core.NetworkContext
function Controller:onMessageReceived(context)
    local request = context:GetApiRequest()

    local endpoint = self:GetEndpoint(request.Method, request.Endpoint)
    if not endpoint then
        self.m_logger:LogTrace("found no endpoint:", request.Endpoint:GetUrl())
        if context.Header.ReturnPort then
            self.m_netPort:GetNetClient():Send(
                context.Header.ReturnIPAddress,
                context.Header.ReturnPort,
                EventNameUsage.RestResponse,
                ResponseTemplates.NotFound("Unable to find endpoint"))
        end
        return
    end

    self.m_logger:LogTrace("found endpoint:", request.Endpoint:GetUrl())
    local response = endpoint:Invoke(request, context)

    if context.Header.ReturnPort then
        self.m_logger:LogTrace("sending response to "" ..
            context.SenderIPAddress .. "" on port: " .. context.Header.ReturnPort .. " ...")
        self.m_netPort:GetNetClient():Send(
            context.Header.ReturnIPAddress,
            context.Header.ReturnPort,
            EventNameUsage.RestResponse,
            response
        )
    else
        self.m_logger:LogTrace("sending no response")
    end
end

---@param endpointMethod Net.Core.Method
---@return table<string, Net.Rest.Api.Server.Endpoint>?
function Controller:GetMethodEndpoints(endpointMethod)
    return self.m_endpoints[endpointMethod]
end

---@param endpointMethod Net.Core.Method
---@param endpointUrl Net.Rest.Uri
---@return Net.Rest.Api.Server.Endpoint?
function Controller:GetEndpoint(endpointMethod, endpointUrl)
    local methodEndpoints = self:GetMethodEndpoints(endpointMethod)
    if not methodEndpoints then
        return
    end

    local bestMatch = nil
    local bestMatchLength = 0
    for uriStr, endpoint in pairs(methodEndpoints) do
        local uriPattern = "^" .. uriStr:gsub("{.*}", ".*") .. "$"
        local endpointUrlStr = tostring(endpointUrl)
        local match = endpointUrlStr:gsub(uriPattern, "")
        local matchLength = endpointUrlStr:len() - match:len()

        if matchLength > bestMatchLength then
            bestMatch = endpoint
            bestMatchLength = matchLength
        end
    end

    return bestMatch
end

---@param method Net.Core.Method
---@param endpointUrl string
---@param task Core.Task
function Controller:AddEndpoint(method, endpointUrl, task)
    local methodEndpoints = self:GetMethodEndpoints(method)
    if not methodEndpoints then
        methodEndpoints = {}
        self.m_endpoints[method] = methodEndpoints
    end

    local endpoint = methodEndpoints[tostring(endpointUrl)]
    if endpoint then
        self.m_logger:LogWarning("Endpoint already exists: " .. tostring(endpointUrl))
        return
    end

    endpoint = Endpoint(endpointUrl, task, self.m_logger:subLogger("Endpoint[" .. endpointUrl .. "]"))
    methodEndpoints[endpointUrl] = endpoint
end

return Utils.Class.Create(Controller, "Net.Rest.Api.Server.Controller")
