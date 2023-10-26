---@meta
local PackageData = {}

PackageData["NetRest__events"] = {
    Location = "Net.Rest.__events",
    Namespace = "Net.Rest.__events",
    IsRunnable = true,
    Data = [[
local JsonSerializer = require("Core.Json.JsonSerializer")

---@class Net.Rest.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    JsonSerializer.Static__Serializer:AddTypeInfos({
        -- Uri
        require("Net.Rest.Uri"):Static__GetType(),

        -- Api
        require("Net.Rest.Api.Request"):Static__GetType(),
        require("Net.Rest.Api.Response"):Static__GetType(),
    })

    require("Net.Rest.Api.NetworkContextExtensions")
    require("Net.Rest.Hosting.HostExtensions")
end

return Events
]]
}

PackageData["NetRestUri"] = {
    Location = "Net.Rest.Uri",
    Namespace = "Net.Rest.Uri",
    IsRunnable = true,
    Data = [[
---@class Net.Rest.Uri : Core.Json.Serializable
---@field private _Path string
---@field private _Query Dictionary<string, string>
---@overload fun(paht: string, query: Dictionary<string, string>) : Net.Rest.Uri
local Uri = {}

---@param uri string
---@return Net.Rest.Uri uri
function Uri.Static__Parse(uri)
    local splittedUri = Utils.String.Split(uri, "?")
    local path = splittedUri[1]

    local query = {}
    local splittedQuery = Utils.String.Split(splittedUri[2], "&")
    for _, queryPart in ipairs(splittedQuery) do
        if not splittedQuery == "" then
            local splittedQueryPart = Utils.String.Split(queryPart, "=")
            query[splittedQueryPart[1}}} = splittedQueryPart[2]
        end
    end

    return Uri(path, query)
end

---@private
---@param path string
---@param query Dictionary<string, string>
function Uri:__init(path, query)
    self._Path = path
    self._Query = query
end

---@param name string
---@param value string
function Uri:AddToQuery(name, value)
    self._Query[name] = value
end

---@return string url
function Uri:GetUrl()
    local str = self._Path
    if Utils.Table.Count(self._Query) > 0 then
        str = str .. "?"
        for name, value in pairs(self._Query) do
            str = str .. name .. "=" .. value .. "&"
        end
    end
    return str
end

---@private
function Uri:__tostring()
    return self:GetUrl()
end

function Uri:Serialize()
    return self._Path, self._Query
end

return Utils.Class.CreateClass(Uri, "Net.Rest.Uri",
    require("Core.Json.Serializable"))
]]
}

PackageData["NetRestApiNetworkContextExtensions"] = {
    Location = "Net.Rest.Api.NetworkContextExtensions",
    Namespace = "Net.Rest.Api.NetworkContextExtensions",
    IsRunnable = true,
    Data = [[
local NetworkContext = require("Net.Core.NetworkContext")

---@class Net.Core.NetworkContext
local NetworkContextExtensions = {}

--- ## Extension from Net.Rest
---@return Net.Rest.Api.Request
function NetworkContextExtensions:GetApiRequest()
	return self.Body
end

--- ## Extension from Net.Rest
---@return Net.Rest.Api.Response
function NetworkContextExtensions:GetApiResponse()
	return self.Body
end

Utils.Class.ExtendClass(NetworkContextExtensions, NetworkContext --{{{@as Net.Core.NetworkContext}}})
]]
}

PackageData["NetRestApiRequest"] = {
    Location = "Net.Rest.Api.Request",
    Namespace = "Net.Rest.Api.Request",
    IsRunnable = true,
    Data = [[
---@class Net.Rest.Api.Request : Core.Json.Serializable
---@field Method Net.Core.Method
---@field Endpoint Net.Rest.Uri
---@field Headers Dictionary<string, any>
---@field Body any
---@overload fun(method: Net.Core.Method, endpoint: Net.Rest.Uri, body: any, headers: Dictionary<string, any>?) : Net.Rest.Api.Request
local Request = {}

---@private
---@param method Net.Core.Method
---@param endpoint Net.Rest.Uri
---@param body any
---@param headers Dictionary<string, any>?
function Request:__init(method, endpoint, body, headers)
    self.Method = method
    self.Endpoint = endpoint
    self.Body = body
    self.Headers = headers or {}
end

---@return Net.Core.Method method, Net.Rest.Uri endpoint, any body, Dictionary<string, any> headers
function Request:Serialize()
    return self.Method, self.Endpoint, self.Body, self.Headers
end

return Utils.Class.CreateClass(Request, "Net.Rest.Api.Request",
    require("Core.Json.Serializable"))
]]
}

PackageData["NetRestApiResponse"] = {
    Location = "Net.Rest.Api.Response",
    Namespace = "Net.Rest.Api.Response",
    IsRunnable = true,
    Data = [[
---@class Net.Rest.Api.Response.Header : Dictionary<string, any>
---@field Code Net.Core.StatusCodes
---@field Message string?

---@class Net.Rest.Api.Response : Core.Json.Serializable
---@field Headers Net.Rest.Api.Response.Header
---@field Body any
---@field WasSuccessfull boolean
---@overload fun(body: any, header: (Net.Rest.Api.Response.Header)?) : Net.Rest.Api.Response
local Response = {}

---@private
---@param body any
---@param header (Net.Rest.Api.Response.Header)?
function Response:__init(body, header)
    self.Body = body
    self.Headers = header or {}
    if type(self.Headers.Code) == 'number' then
        self.WasSuccessfull = self.Headers.Code < 300
    else
        self.WasSuccessfull = false
    end
end

---@return Net.Rest.Api.Response.Header headers, any body
function Response:Serialize()
    return self.Headers, self.Body
end

---@param headers Net.Rest.Api.Response.Header
---@param body any
---@return Net.Rest.Api.Response
function Response:Static__Deserialize(headers, body)
    return self(body, headers)
end

return Utils.Class.CreateClass(Response, "Net.Rest.Api.Response",
    require("Core.Json.Serializable"))
]]
}

PackageData["NetRestApiClientClient"] = {
    Location = "Net.Rest.Api.Client.Client",
    Namespace = "Net.Rest.Api.Client.Client",
    IsRunnable = true,
    Data = [[
local EventNameUsage = require("Core.Usage.Usage_EventName")
local StatusCodes = require("Net.Core.StatusCodes")

local Response = require('Net.Rest.Api.Response')

local DEFAULT_TIMEOUT = 5

---@class Net.Rest.Api.Client : object
---@field ServerIPAddress Net.Core.IPAddress
---@field ServerPort integer
---@field ReturnPort integer
---@field private _NetClient Net.Core.NetworkClient
---@field private _Logger Core.Logger
---@overload fun(serverIPAddress: Net.Core.IPAddress, serverPort: integer, returnPort: integer, netClient: Net.Core.NetworkClient, logger: Core.Logger) : Net.Rest.Api.Client
local Client = {}

---@private
---@param serverIPAddress Net.Core.IPAddress
---@param serverPort integer
---@param returnPort integer
---@param netClient Net.Core.NetworkClient
---@param logger Core.Logger
function Client:__init(serverIPAddress, serverPort, returnPort, netClient, logger)
    self.ServerIPAddress = serverIPAddress
    self.ServerPort = serverPort
    self.ReturnPort = returnPort
    self._NetClient = netClient
    self._Logger = logger
end

---@param request Net.Rest.Api.Request
---@param timeout integer?
---@return Net.Rest.Api.Response response
function Client:Send(request, timeout)
    local networkFuture = self._NetClient:CreateEventFuture(
        EventNameUsage.RestResponse,
        self.ReturnPort,
        timeout or DEFAULT_TIMEOUT)

    self._NetClient:Send(self.ServerIPAddress, self.ServerPort, EventNameUsage.RestRequest, request,
        { ReturnPort = self.ReturnPort })

    local context = networkFuture:Wait()
    if not context then
        return Response(nil, { Code = StatusCodes.Status408RequestTimeout })
    end

    return context:GetApiResponse()
end

return Utils.Class.CreateClass(Client, 'Net.Rest.Api.Client')
]]
}

PackageData["NetRestApiServerController"] = {
    Location = "Net.Rest.Api.Server.Controller",
    Namespace = "Net.Rest.Api.Server.Controller",
    IsRunnable = true,
    Data = [[
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
    local response = endpoint:Invoke(request, context)

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
]]
}

PackageData["NetRestApiServerEndpoint"] = {
    Location = "Net.Rest.Api.Server.Endpoint",
    Namespace = "Net.Rest.Api.Server.Endpoint",
    IsRunnable = true,
    Data = [[
local EventNameUsage    = require("Core.Usage.Usage_EventName")
local StatusCodes       = require("Net.Core.StatusCodes")

local ResponseTemplates = require('Net.Rest.Api.Server.ResponseTemplates')

local UUID              = require("Core.UUID")

---@class Net.Rest.Api.Server.Endpoint : object
---@field private _EndpointUriPattern string
---@field private _EndpointUriTemplate string
---@field private _ParameterTypes string[]
---@field private _Task Core.Task
---@field private _Logger Core.Logger
---@overload fun(endpointUriPattern: string, task: Core.Task, logger: Core.Logger) : Net.Rest.Api.Server.Endpoint
local Endpoint          = {}

---@private
---@param endpointUriPattern string
---@param task Core.Task
---@param logger Core.Logger
function Endpoint:__init(endpointUriPattern, task, logger)
    self._EndpointUriPattern = endpointUriPattern
    self._EndpointUriTemplate = endpointUriPattern:gsub("{[a-zA-Z0-9]*:[a-zA-Z0-9\\.]*}", "(.+)")

    self._ParameterTypes = {}
    for parameterType in endpointUriPattern:gmatch("{[a-zA-Z0-9]*:([a-zA-Z0-9\\.]*)}") do
        table.insert(self._ParameterTypes, parameterType)
    end

    self._Task = task
    self._Logger = logger
end

---@private
---@param uri string
---@return any[] parameters
function Endpoint:GetUriParameters(uri)
    local parameters = { uri:match(self._EndpointUriTemplate) }

    local parameterTypes = self._ParameterTypes
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
        response = self._Task:Execute(request.Body, request, context)
    else
        response = self._Task:Execute(table.unpack(uriParameters), request.Body, request, context)
    end
    self._Task:Close()

    if not self._Task:IsSuccess() then
        response = ResponseTemplates.InternalServerError(self._Task:GetTraceback() or "no error")
    end

    return response
end

---@param request Net.Rest.Api.Request
---@param context Net.Core.NetworkContext
---@return Net.Rest.Api.Response response
function Endpoint:Invoke(request, context)
    self._Logger:LogTrace('executing...')
    ___logger:setLogger(self._Logger)

    local response
    local uriParameters, parseError = self:ParseUriParameters(tostring(request.Endpoint))
    if parseError then
        response = ResponseTemplates.InternalServerError(parseError or "uri parameters could not be parsed")
        return response
    end

    response = self:Execute(uriParameters, request, context)

    if response.WasSuccessfull then
        self._Logger:LogDebug('request finished with status code: ' .. response.Headers.Code)
    else
        if response.Headers.Code == StatusCodes.Status500InternalServerError then
            self._Logger:LogError('request finished with status code: '
                .. response.Headers.Code .. " with message: '" .. response.Headers.Message .. "'")
        else
            self._Logger:LogWarning('request finished with status code: '
                .. response.Headers.Code .. " with message: '" .. response.Headers.Message .. "'")
        end
    end

    return response
end

return Utils.Class.CreateClass(Endpoint, "Net.Rest.Api.Server.Endpoint")
]]
}

PackageData["NetRestApiServerEndpointBase"] = {
    Location = "Net.Rest.Api.Server.EndpointBase",
    Namespace = "Net.Rest.Api.Server.EndpointBase",
    IsRunnable = true,
    Data = [[
local Task = require("Core.Task")

local ResponseTemplates = require('Net.Rest.Api.Server.ResponseTemplates')

---@class Net.Rest.Api.Server.EndpointBase : object
---@field protected _Logger Core.Logger
---@field protected ApiController Net.Rest.Api.Server.Controller
---@field protected Templates Core.RestNew.Api.Server.EndpointBase.ResponseTemplates
---@overload fun(endpointLogger: Core.Logger, apiController: Net.Rest.Api.Server.Controller) : Net.Rest.Api.Server.EndpointBase
local EndpointBase = {}

---@private
---@param endpointLogger Core.Logger
---@param apiController Net.Rest.Api.Server.Controller
function EndpointBase:__init(endpointLogger, apiController)
	self._Logger = endpointLogger
	self.ApiController = apiController
end

---@param method Net.Core.Method
---@param endpointUrl string
---@param func function
function EndpointBase:AddEndpoint(method, endpointUrl, func)
	self.ApiController:AddEndpoint(method, endpointUrl, Task(func, self))
end

---@class Core.RestNew.Api.Server.EndpointBase.ResponseTemplates
local Templates = {}

---@param value any
---@return Net.Rest.Api.Response
function Templates:Ok(value)
	return ResponseTemplates.Ok(value)
end

---@param message string
---@return Net.Rest.Api.Response
function Templates:BadRequest(message)
	return ResponseTemplates.BadRequest(message)
end

---@param message string
---@return Net.Rest.Api.Response
function Templates:NotFound(message)
	return ResponseTemplates.NotFound(message)
end

---@param message string
---@return Net.Rest.Api.Response
function Templates:InternalServerError(message)
	return ResponseTemplates.InternalServerError(message)
end

EndpointBase.Templates = Templates

return Utils.Class.CreateClass(EndpointBase, 'Net.Rest.Api.Server.EndpointBase')
]]
}

PackageData["NetRestApiServerResponseTemplates"] = {
    Location = "Net.Rest.Api.Server.ResponseTemplates",
    Namespace = "Net.Rest.Api.Server.ResponseTemplates",
    IsRunnable = true,
    Data = [[
local StatusCodes = require('Net.Core.StatusCodes')
local Response = require('Net.Rest.Api.Response')

---@class Net.Rest.Api.Server.RestApiResponseTemplates
local ResponseTemplates = {}

---@param value any
---@return Net.Rest.Api.Response
function ResponseTemplates.Ok(value)
	return Response(value, { Code = StatusCodes.Status200OK })
end

function ResponseTemplates.Accepted(value)
	return Response(value, { Code = StatusCodes.Status202Accepted })
end

---@param message string
---@return Net.Rest.Api.Response
function ResponseTemplates.BadRequest(message)
	return Response(nil, { Code = StatusCodes.Status400BadRequest, Message = message })
end

---@param message string
---@return Net.Rest.Api.Response
function ResponseTemplates.NotFound(message)
	return Response(nil, { Code = StatusCodes.Status404NotFound, Message = message })
end

---@param message string
---@return Net.Rest.Api.Response
function ResponseTemplates.InternalServerError(message)
	return Response(nil, { Code = StatusCodes.Status500InternalServerError, Message = message })
end

return ResponseTemplates
]]
}

PackageData["NetRestHostingHostExtensions"] = {
    Location = "Net.Rest.Hosting.HostExtensions",
    Namespace = "Net.Rest.Hosting.HostExtensions",
    IsRunnable = true,
    Data = [[
---@type Out<Github_Loading.Module>
local Host = {}
if not PackageLoader:TryGetModule("Hosting.Host", Host) then
    return
end
---@type Hosting.Host
Host = Host.Value:Load()
-- Run only if module Hosting.Host is loaded

local ApiController = require("Net.Rest.Api.Server.Controller")

---@class Hosting.Host
---@field package ApiControllers Dictionary<Net.Core.Port, Net.Rest.Api.Server.Controller>
---@field package Endpoints Net.Rest.Api.Server.EndpointBase[]
local HostExtensions = {}

---@param port Net.Core.Port
---@param endpointLogger Core.Logger
---@return Net.Rest.Api.Server.Controller apiController
function HostExtensions:GetOrCreateApiController(port, endpointLogger)
    if not self.ApiControllers then
        self.ApiControllers = {}
    end

    local apiController = self.ApiControllers[port]
    if not apiController then
        local netPort = self:GetNetworkClient():GetOrCreateNetworkPort(port)
        apiController = ApiController(netPort, endpointLogger:subLogger("ApiController"))
        self.ApiControllers[port] = apiController
        netPort:OpenPort()
    end

    return apiController
end

---@param port Net.Core.Port
---@param endpointName string
---@param endpointBase Net.Rest.Api.Server.EndpointBase
---@param ... any constructor args that are not logger and apiController
function HostExtensions:AddEndpoint(port, endpointName, endpointBase, ...)
    if not self.Endpoints then
        self.Endpoints = {}
    end

    local endpointLogger = self._Logger:subLogger("Endpoint[" .. endpointName .. "]")
    local apiController = self:GetOrCreateApiController(port, endpointLogger)

    table.insert(self.Endpoints, endpointBase(endpointLogger, apiController, ...))
end

return Utils.Class.ExtendClass(HostExtensions, Host)
]]
}

return PackageData
