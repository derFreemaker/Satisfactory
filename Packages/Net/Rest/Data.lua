local Data={
["Net.Rest.__events"] = [[
local JsonSerializer = require("Core.Json.JsonSerializer")

---@class Net.Rest.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    JsonSerializer.Static__Serializer:AddClasses({
        -- Uri
        require("Net.Rest.Uri"),

        -- Api
        require("Net.Rest.Api.Request"),
        require("Net.Rest.Api.Response"),
    })

    require("Net.Rest.Api.NetworkContextExtensions")
    require("Net.Rest.Hosting.HostExtensions")
end

return Events

]],
["Net.Rest.Uri"] = [[
---@class Net.Rest.Uri : Core.Json.Serializable
---@field private m_path string
---@field private m_query table<string, string>
---@overload fun(paht: string, query: table<string, string>) : Net.Rest.Uri
local Uri = {}

---@param uri string
---@return Net.Rest.Uri uri
function Uri.Static__Parse(uri)
    local splittedUri = Utils.String.Split(uri, "?")
    local path = splittedUri[1]

    local query = {}
    local splittedQuery = Utils.String.Split(splittedUri[2], "&")

    if not splittedQuery == "" then
        for _, queryPart in ipairs(splittedQuery) do
            local splittedQueryPart = Utils.String.Split(queryPart, "=")
            query[splittedQueryPart[1}}} = splittedQueryPart[2]
        end
    end

    return Uri(path, query)
end

---@private
---@param path string
---@param query table<string, string>
function Uri:__init(path, query)
    self.m_path = path
    self.m_query = query or {}
end

---@param name string
---@param value string
function Uri:AddToQuery(name, value)
    self.m_query[name] = value
end

---@return string url
function Uri:GetUrl()
    local str = self.m_path
    if #self.m_query > 0 then
        str = str .. "?"
        for name, value in pairs(self.m_query) do
            str = str .. name .. "=" .. value .. "&"
        end
    end
    return str
end

---@private
function Uri:__tostring()
    return self:GetUrl()
end

---@return string path, table<string, string> query
function Uri:Serialize()
    return self.m_path, self.m_query
end

return Utils.Class.Create(Uri, "Net.Rest.Uri",
    require("Core.Json.Serializable"))

]],
["Net.Rest.Api.NetworkContextExtensions"] = [[
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

Utils.Class.Extend(NetworkContext, NetworkContextExtensions)

]],
["Net.Rest.Api.Request"] = [[
---@class Net.Rest.Api.Request : Core.Json.Serializable
---@field Method Net.Core.Method
---@field Endpoint Net.Rest.Uri
---@field Headers table<string, any>
---@field Body any
---@overload fun(method: Net.Core.Method, endpoint: Net.Rest.Uri, body: any, headers: table<string, any>?) : Net.Rest.Api.Request
local Request = {}

---@private
---@param method Net.Core.Method
---@param endpoint Net.Rest.Uri
---@param body any
---@param headers table<string, any>?
function Request:__init(method, endpoint, body, headers)
    self.Method = method
    self.Endpoint = endpoint
    self.Body = body
    self.Headers = headers or {}
end

---@return Net.Core.Method method, Net.Rest.Uri endpoint, any body, table<string, any> headers
function Request:Serialize()
    return self.Method, self.Endpoint, self.Body, self.Headers
end

return Utils.Class.Create(Request, "Net.Rest.Api.Request",
    require("Core.Json.Serializable"))

]],
["Net.Rest.Api.Response"] = [[
---@class Net.Rest.Api.Response.Header : table<string, any>
---@field Code Net.Core.StatusCodes
---@field Message string?

---@class Net.Rest.Api.Response : Core.Json.Serializable
---@field Headers Net.Rest.Api.Response.Header
---@field Body any
---@field WasSuccessful boolean
---@overload fun(body: any, header: (Net.Rest.Api.Response.Header)?) : Net.Rest.Api.Response
local Response = {}

---@private
---@param body any
---@param header (Net.Rest.Api.Response.Header)?
function Response:__init(body, header)
    self.Body = body
    self.Headers = header or {}
    if type(self.Headers.Code) == 'number' then
        self.WasSuccessful = self.Headers.Code < 300
    else
        self.WasSuccessful = false
    end
end

---@return Net.Rest.Api.Response.Header headers, any body
function Response:Serialize()
    return self.Body, self.Headers
end

return Utils.Class.Create(Response, "Net.Rest.Api.Response",
    require("Core.Json.Serializable"))

]],
["Net.Rest.Api.Client.Client"] = [[
local EventNameUsage = require("Core.Usage.Usage_EventName")
local StatusCodes = require("Net.Core.StatusCodes")

local Response = require('Net.Rest.Api.Response')

local DEFAULT_TIMEOUT = 5

---@class Net.Rest.Api.Client : object
---@field ServerIPAddress Net.Core.IPAddress
---@field ServerPort integer
---@field ReturnPort integer
---@field private m_netClient Net.Core.NetworkClient
---@field private m_logger Core.Logger
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
    self.m_netClient = netClient
    self.m_logger = logger
end

---@param request Net.Rest.Api.Request
---@param timeout integer?
---@return Net.Rest.Api.Response response
function Client:Send(request, timeout)
    local networkFuture = self.m_netClient:CreateEventFuture(
        EventNameUsage.RestResponse,
        self.ReturnPort,
        timeout or DEFAULT_TIMEOUT)

    self.m_netClient:Send(self.ServerIPAddress, self.ServerPort, EventNameUsage.RestRequest, request,
        { ReturnPort = self.ReturnPort })

    local context = networkFuture:Wait()
    if not context then
        return Response(nil, { Code = StatusCodes.Status408RequestTimeout })
    end

    return context:GetApiResponse()
end

return Utils.Class.Create(Client, 'Net.Rest.Api.Client')

]],
["Net.Rest.Api.Server.Controller"] = [[
local EventNameUsage = require("Core.Usage.Usage_EventName")

local Task = require('Core.Common.Task')

local Endpoint = require("Net.Rest.Api.Server.Endpoint")

local ResponseTemplates = require('Net.Rest.Api.Server.ResponseTemplates')

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
        self.m_logger:LogTrace('found no endpoint:', request.Endpoint:GetUrl())
        if context.Header.ReturnPort then
            self.m_netPort:GetNetClient():Send(
                context.Header.ReturnIPAddress,
                context.Header.ReturnPort,
                EventNameUsage.RestResponse,
                ResponseTemplates.NotFound('Unable to find endpoint'))
        end
        return
    end

    self.m_logger:LogTrace('found endpoint:', request.Endpoint:GetUrl())
    local response = endpoint:Invoke(request, context)

    if context.Header.ReturnPort then
        self.m_logger:LogTrace("sending response to '" ..
            context.SenderIPAddress .. "' on port: " .. context.Header.ReturnPort .. " ...")
        self.m_netPort:GetNetClient():Send(
            context.Header.ReturnIPAddress,
            context.Header.ReturnPort,
            EventNameUsage.RestResponse,
            response
        )
    else
        self.m_logger:LogTrace('sending no response')
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
        self.m_logger:LogWarning('Endpoint already exists: ' .. tostring(endpointUrl))
        return
    end

    endpoint = Endpoint(endpointUrl, task, self.m_logger:subLogger("Endpoint[" .. endpointUrl .. "]"))
    methodEndpoints[endpointUrl] = endpoint
end

return Utils.Class.Create(Controller, "Net.Rest.Api.Server.Controller")

]],
["Net.Rest.Api.Server.Endpoint"] = [[
local ResponseTemplates = require('Net.Rest.Api.Server.ResponseTemplates')

local UUID              = require("Core.Common.UUID")

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
    if #self.m_parameterTypes == 0 then
        return {}
    end

    local parameters = { uri:match(self.m_endpointUriTemplate) }

    for i = 1, #parameters, 1 do
        local parameterType = self.m_parameterTypes[i]
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
        self.m_logger:LogError("endpoint failed with error:", parseError)
        self.m_logger:LogDebug('request finished with status code: ' .. response.Headers.Code)
        return response
    end

    response = self:Execute(uriParameters, request, context)
    self.m_logger:LogDebug('request finished with status code: ' .. response.Headers.Code)

    return response
end

return Utils.Class.Create(Endpoint, "Net.Rest.Api.Server.Endpoint")

]],
["Net.Rest.Api.Server.EndpointBase"] = [[
local Task = require("Core.Common.Task")

local ResponseTemplates = require('Net.Rest.Api.Server.ResponseTemplates')

---@class Net.Rest.Api.Server.EndpointBase : object
---@field protected Logger Core.Logger
---@field protected ApiController Net.Rest.Api.Server.Controller
---@field protected Templates Core.RestNew.Api.Server.EndpointBase.ResponseTemplates
---@overload fun(endpointLogger: Core.Logger, apiController: Net.Rest.Api.Server.Controller) : Net.Rest.Api.Server.EndpointBase
local EndpointBase = {}

---@private
---@param endpointLogger Core.Logger
---@param apiController Net.Rest.Api.Server.Controller
function EndpointBase:__init(endpointLogger, apiController)
	self.Logger = endpointLogger
	self.ApiController = apiController
end

---@param method Net.Core.Method
---@param endpointUrl string
---@param func fun(...) : Net.Rest.Api.Response
function EndpointBase:AddEndpoint(method, endpointUrl, func)
	self.ApiController:AddEndpoint(method, endpointUrl, Task(function(...)
		func(self, ...)
	end))
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

return Utils.Class.Create(EndpointBase, 'Net.Rest.Api.Server.EndpointBase')

]],
["Net.Rest.Api.Server.ResponseTemplates"] = [[
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

]],
["Net.Rest.Hosting.HostExtensions"] = [[
---@type Out<Github_Loading.Module>
local Host = {}
if not PackageLoader:TryGetModule("Hosting.Host", Host) then
    return
end
---@type Hosting.Host
Host = Host.Value:Load()

local ApiController = require("Net.Rest.Api.Server.Controller")

---@class Hosting.Host
---@field package ApiControllers table<Net.Core.Port, Net.Rest.Api.Server.Controller>
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

    local endpointLogger = self:CreateLogger("Endpoint[" .. endpointName .. "]")
    local apiController = self:GetOrCreateApiController(port, endpointLogger)

    table.insert(self.Endpoints, endpointBase(endpointLogger, apiController, ...))
end

return Utils.Class.Extend(Host, HostExtensions)

]],
}

return Data
