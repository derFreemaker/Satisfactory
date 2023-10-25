local EventNameUsage = require("Core.Usage.Usage_EventName")

local Task = require('Core.Task')

local Method = require('Net.Core.Method')
local Endpoint = require("Net.Rest.Api.Server.Endpoint")

local ResponseTemplates = require('Net.Rest.Api.Server.ResponseTemplates')

---@class Net.Rest.Api.Server.Controller : object
---@field private _Endpoints Dictionary<Net.Core.Method, Dictionary<string, Net.Rest.Api.Server.Endpoint>>
---@field private _NetPort Net.Core.NetworkPort
---@field private _Logger Core.Logger
---@overload fun(netPort: Net.Core.NetworkPort, logger: Core.Logger) : Net.Rest.Api.Server.Controller
local Controller = {}

---@private
---@param netPort Net.Core.NetworkPort
---@param logger Core.Logger
function Controller:__init(netPort, logger)
    self._Endpoints = {}
    self._NetPort = netPort
    self._Logger = logger
    netPort:AddListener(EventNameUsage.RestRequest, Task(self.onMessageRecieved, self))
end

---@private
---@param context Net.Core.NetworkContext
function Controller:onMessageRecieved(context)
    local request = context:GetApiRequest()

    local endpoint = self:GetEndpoint(request.Method, request.Endpoint)
    if not endpoint then
        self._Logger:LogTrace('found no endpoint:', request.Endpoint)
        if context.Header.ReturnPort then
            self._NetPort:GetNetClient():Send(
                context.Header.ReturnIPAddress,
                context.Header.ReturnPort,
                EventNameUsage.RestResponse,
                ResponseTemplates.NotFound('Unable to find endpoint'))
        end
        return
    end
    self._Logger:LogTrace('found endpoint:', request.Endpoint)
    local response = endpoint:Execute(request, context)

    if context.Header.ReturnPort then
        self._Logger:LogTrace("sending response to '" ..
            context.SenderIPAddress .. "' on port: " .. context.Header.ReturnPort .. " ...")
        self._NetPort:GetNetClient():Send(
            context.Header.ReturnIPAddress,
            context.Header.ReturnPort,
            EventNameUsage.RestResponse,
            response
        )
    else
        self._Logger:LogTrace('sending no response')
    end
end

---@param endpointMethod Net.Core.Method
---@return Dictionary<string, Net.Rest.Api.Server.Endpoint>?
function Controller:GetMethodEndpoints(endpointMethod)
    return self._Endpoints[endpointMethod]
end

---@param endpointMethod Net.Core.Method
---@param endpointUrl Net.Rest.Uri
---@return Net.Rest.Api.Server.Endpoint?
function Controller:GetEndpoint(endpointMethod, endpointUrl)
    local methodEndpoints = self:GetMethodEndpoints(endpointMethod)
    if not methodEndpoints then
        return
    end

    for uriStr, endpoint in pairs(methodEndpoints) do
        local uriPattern = "^" .. uriStr:gsub("{.*}", ".*") .. "$"
        if tostring(endpointUrl):match(uriPattern) then
            self._Logger:LogDebug("found endpoint: " .. tostring(endpointUrl) .. " -> " .. uriStr)
            return endpoint
        end
    end
end

---@param method Net.Core.Method
---@param endpointUrl string
---@param task Core.Task
function Controller:AddEndpoint(method, endpointUrl, task)
    local methodEndpoints = self:GetMethodEndpoints(method)
    if not methodEndpoints then
        methodEndpoints = {}
        self._Endpoints[method] = methodEndpoints
    end

    local endpoint = methodEndpoints[tostring(endpointUrl)]
    if endpoint then
        self._Logger:LogWarning('Endpoint already exists: ' .. tostring(endpointUrl))
        return
    end

    endpoint = Endpoint(endpointUrl, task, self._Logger:subLogger("Endpoint[" .. endpointUrl .. "]"))
    methodEndpoints[endpointUrl] = endpoint
end

return Utils.Class.CreateClass(Controller, "Net.Rest.Api.Server.Controller")
