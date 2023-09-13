local PackageData = {}

-- ########## Net.Rest ##########

-- ########## Net.Rest.RestApi ##########

-- ########## Net.Rest.RestApi.Client ##########

PackageData.PksKdJNx = {
    Namespace = "Net.Rest.RestApi.Client.RestApiNetworkClient",
    Name = "RestApiNetworkClient",
    FullName = "RestApiNetworkClient.lua",
    IsRunnable = true,
    Data = [[
local RestApiResponse = require("Core.RestApi.RestApiResponse")

---@class Core.RestApi.Client.RestApiClient : object
---@field ServerIPAddress string
---@field ServerPort integer
---@field ReturnPort integer
---@field private NetClient Core.Net.NetworkClient
---@field private logger Core.Logger
---@overload fun(serverIPAddress: string, serverPort: integer, returnPort: integer, netClient: Core.Net.NetworkClient, logger: Core.Logger) : Core.RestApi.Client.RestApiClient
local RestApiClient = {}

---@private
---@param serverIPAddress string
---@param serverPort integer
---@param returnPort integer
---@param netClient Core.Net.NetworkClient
---@param logger Core.Logger
function RestApiClient:__init(serverIPAddress, serverPort, returnPort, netClient, logger)
    self.ServerIPAddress = serverIPAddress
    self.ServerPort = serverPort
    self.ReturnPort = returnPort
    self.NetClient = netClient
    self.logger = logger
end

---@param request Core.RestApi.RestApiRequest
---@return Core.RestApi.RestApiResponse response
function RestApiClient:request(request)
    self.NetClient:SendMessage(self.ServerIPAddress, self.ServerPort, "Rest-Request", request:ExtractData(), { ReturnPort = self.ReturnPort })
    local context = self.NetClient:WaitForEvent("Rest-Response", self.ReturnPort, 5)
    if not context then
        return RestApiResponse(nil, { Code = 408 })
    end
    local response = context:ToApiResponse()
    return response
end

return Utils.Class.CreateClass(RestApiClient, "Core.RestApi.Client.RestApiNetworkClient")
]]
}

-- ########## Net.Rest.RestApi.Client ########## --

-- ########## Net.Rest.RestApi.Server ##########

PackageData.RONgYwHx = {
    Namespace = "Net.Rest.RestApi.Server.RestApiController",
    Name = "RestApiController",
    FullName = "RestApiController.lua",
    IsRunnable = true,
    Data = [[
local Task = require("Core.Task")
local RestApiEndpoint = require("Core.RestApi.Server.RestApiEndpoint")
local RestApiResponseTemplates = require("Core.RestApi.Server.RestApiResponseTemplates")
local RestApiMethod = require("Core.RestApi.RestApiMethod")
local RestApiRequest = require("Core.RestApi.RestApiRequest")

---@class Core.RestApi.Server.RestApiController : object
---@field Endpoints Dictionary<string, Core.RestApi.Server.RestApiEndpoint>
---@field private netPort Core.Net.NetworkPort
---@field private logger Core.Logger
---@overload fun(netPort: Core.Net.NetworkPort, logger: Core.Logger) : Core.RestApi.Server.RestApiController
local RestApiController = {}

---@private
---@param netPort Core.Net.NetworkPort
---@param logger Core.Logger
function RestApiController:__init(netPort, logger)
    self.Endpoints = {}
    self.netPort = netPort
    self.logger = logger
    netPort:AddListener("Rest-Request", Task(self.onMessageRecieved, self))
end

---@private
---@param context Core.Net.NetworkContext
function RestApiController:onMessageRecieved(context)
    local request = context:ToApiRequest()
    self.logger:LogDebug("recieved request on endpoint: '" .. request.Endpoint .. "'")
    local endpoint = self:GetEndpoint(request.Method, request.Endpoint)
    if endpoint == nil then
        self.logger:LogTrace("found no endpoint")
        if context.Header.ReturnPort then
            self.netPort:GetNetClient():SendMessage(context.SenderIPAddress, context.Header.ReturnPort,
                "Rest-Response", RestApiResponseTemplates.NotFound("Unable to find endpoint"):ExtractData())
        end
        return
    end
    self.logger:LogTrace("found endpoint: ".. request.Endpoint)
    endpoint:Execute(request, context, self.netPort:GetNetClient())
end

---@param method Core.RestApi.RestApiMethod
---@param endpointName string
---@return Core.RestApi.Server.RestApiEndpoint?
function RestApiController:GetEndpoint(method, endpointName)
    for name, endpoint in pairs(self.Endpoints) do
        if name == method .."__".. endpointName then
            return endpoint
        end
    end
end

---@param method Core.RestApi.RestApiMethod
---@param name string
---@param task Core.Task
---@return Core.RestApi.Server.RestApiController
function RestApiController:AddEndpoint(method , name, task)
    if self:GetEndpoint(method, name) ~= nil then
        error("Endpoint allready exists")
    end
local endpointName = method .. "__" .. name
    self.Endpoints[endpointName] = RestApiEndpoint(task, self.logger:subLogger("RestApiEndpoint[" .. endpointName .. "]"))
    self.logger:LogTrace("Added endpoint: '".. method .."' -> '" .. name .. "'")
    return self
end

---@param endpoint Core.RestApi.Server.RestApiEndpointBase
function RestApiController:AddRestApiEndpointBase(endpoint)
    for name, func in pairs(endpoint) do
        if type(name) == "string" and type(func) == "function" then
            local method, endpointName = name:match("^(.+)__(.+)$")
            if method ~= nil and endpoint ~= nil and RestApiMethod[method] then
                self:AddEndpoint(method, endpointName, Task(func, endpoint))
            end
        end
    end
end

return Utils.Class.CreateClass(RestApiController, "Core.RestApi.Server.RestApiController")
]]
}

PackageData.seyrvpeX = {
    Namespace = "Net.Rest.RestApi.Server.RestApiEndpoint",
    Name = "RestApiEndpoint",
    FullName = "RestApiEndpoint.lua",
    IsRunnable = true,
    Data = [[
local RestApiResponseTemplates = require("Core.RestApi.Server.RestApiResponseTemplates")

---@class Core.RestApi.Server.RestApiEndpoint : object
---@field private task Core.Task
---@field private logger Core.Logger
---@overload fun(task: Core.Task, logger: Core.Logger) : Core.RestApi.Server.RestApiEndpoint
local RestApiEndpoint = {}

---@private
---@param task Core.Task
---@param logger Core.Logger
function RestApiEndpoint:__init(task, logger)
    self.task = task
    self.logger = logger
end

---@param request Core.RestApi.RestApiRequest
---@param context Core.Net.NetworkContext
---@param netClient Core.Net.NetworkClient
function RestApiEndpoint:Execute(request, context, netClient)
    self.logger:LogTrace("executing...")
    ___logger:setLogger(self.logger)
    self.task:Execute(request)
    self.task:LogError(self.logger)
    ___logger:revert()
    ---@type Core.RestApi.RestApiResponse
    local response = self.task:GetResults()
    if not self.task:IsSuccess() then
        response = RestApiResponseTemplates.InternalServerError(tostring(self.task:GetTraceback()))
    end
    if context.Header.ReturnPort then
        self.logger:LogTrace("sending response to '" .. context.SenderIPAddress .. "' on port: " .. context.Header.ReturnPort .. "...")
        netClient:SendMessage(context.SenderIPAddress, context.Header.ReturnPort, "Rest-Response", response:ExtractData())
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
]]
}

PackageData.TtiCTjCx = {
    Namespace = "Net.Rest.RestApi.Server.RestApiEndpointBase",
    Name = "RestApiEndpointBase",
    FullName = "RestApiEndpointBase.lua",
    IsRunnable = true,
    Data = [[
local RestApiResponseTemplates = require("Core.RestApi.Server.RestApiResponseTemplates")

---@class Core.RestApi.Server.RestApiEndpointBase : object
---@field protected Templates Core.RestApi.Server.RestApiEndpointBase.RestApiResponseTemplates
local RestApiEndpointBase = {}

---@return fun(self: object, key: any) : key: any, value: any
---@return Core.RestApi.Server.RestApiEndpointBase tbl
---@return any startPoint
function RestApiEndpointBase:__pairs()
    local function iterator(tbl, key)
        local newKey, value = next(tbl, key)
        if type(newKey) == "string" and type(value) == "function" then
            return newKey, value
        end
        if newKey == nil and value == nil then
            return nil, nil
        end
        return iterator(tbl, newKey)
    end
    return iterator, self, nil
end

---@class Core.RestApi.Server.RestApiEndpointBase.RestApiResponseTemplates
RestApiEndpointBase.Templates = {}

---@param value any
---@return Core.RestApi.RestApiResponse
function RestApiEndpointBase.Templates:Ok(value)
    return RestApiResponseTemplates.Ok(value)
end

---@param message string
---@return Core.RestApi.RestApiResponse
function RestApiEndpointBase.Templates:BadRequest(message)
    return RestApiResponseTemplates.BadRequest(message)
end

---@param message string
---@return Core.RestApi.RestApiResponse
function RestApiEndpointBase.Templates:NotFound(message)
    return RestApiResponseTemplates.NotFound(message)
end

---@param message string
---@return Core.RestApi.RestApiResponse
function RestApiEndpointBase.Templates:InternalServerError(message)
    return RestApiResponseTemplates.InternalServerError(message)
end

return Utils.Class.CreateClass(RestApiEndpointBase, "Core.RestApi.Server.RestApiControllerBase")
]]
}

PackageData.vISNqcZX = {
    Namespace = "Net.Rest.RestApi.Server.RestApiResponseTemplates",
    Name = "RestApiResponseTemplates",
    FullName = "RestApiResponseTemplates.lua",
    IsRunnable = true,
    Data = [[
local StatusCodes = require("Core.RestApi.StatusCodes")
local RestApiResponse = require("Core.RestApi.RestApiResponse")

---@class Core.RestApi.Server.RestApiResponseTemplates
local RestApiResponseTemplates = {}

---@param value any
---@return Core.RestApi.RestApiResponse
function RestApiResponseTemplates.Ok(value)
    return RestApiResponse(value, { Code = StatusCodes.Status200OK })
end

---@param message string
---@return Core.RestApi.RestApiResponse
function RestApiResponseTemplates.BadRequest(message)
    return RestApiResponse(nil, { Code = StatusCodes.Status400BadRequest, Message = message })
end

---@param message string
---@return Core.RestApi.RestApiResponse
function RestApiResponseTemplates.NotFound(message)
    return RestApiResponse(nil, { Code = StatusCodes.Status404NotFound, Message = message })
end

---@param message string
---@return Core.RestApi.RestApiResponse
function RestApiResponseTemplates.InternalServerError(message)
    return RestApiResponse(nil, { Code = StatusCodes.Status500InternalServerError, Message = message })
end

return RestApiResponseTemplates
]]
}

-- ########## Net.Rest.RestApi.Server ########## --

PackageData.WXDYOWwx = {
    Namespace = "Net.Rest.RestApi.RestApiMethod",
    Name = "RestApiMethod",
    FullName = "RestApiMethod.lua",
    IsRunnable = true,
    Data = [[
---@enum Core.RestApi.RestApiMethod
local RestApiMethods = {
    GET = "GET",
    HEAD = "HEAD",
    POST = "POST",
    PUT = "PUT",
    CREATE = "CREATE",
    DELETE = "DELETE",
    CONNECT = "CONNECT",
    OPTIONS = "OPTIONS",
    TRACE = "TRACE",
    PATCH = "PATCH"
}

return RestApiMethods
]]
}

PackageData.xnnklPUX = {
    Namespace = "Net.Rest.RestApi.RestApiRequest",
    Name = "RestApiRequest",
    FullName = "RestApiRequest.lua",
    IsRunnable = true,
    Data = [[
---@class Core.RestApi.RestApiRequest : object
---@field Method Core.RestApi.RestApiMethod
---@field Endpoint string
---@field Headers Dictionary<string, any>
---@field Body any
---@overload fun(method: Core.RestApi.RestApiMethod, endpoint: string, body: any, headers: Dictionary<string, any>?) : Core.RestApi.RestApiRequest
local RestApiRequest = {}

---@private
---@param method Core.RestApi.RestApiMethod
---@param endpoint string
---@param body any
---@param headers Dictionary<string, any>?
function RestApiRequest:__init(method, endpoint, body, headers)
    self.Method = method
    self.Endpoint = endpoint
    self.Headers = headers or {}
    self.Body = body
end

---@return table
function RestApiRequest:ExtractData()
    return {
        Method = self.Method,
        Endpoint = self.Endpoint,
        Headers = self.Headers,
        Body = self.Body
    }
end

return Utils.Class.CreateClass(RestApiRequest, "Core.RestApi.RestApiRequest")
]]
}

PackageData.YCXvIIrx = {
    Namespace = "Net.Rest.RestApi.RestApiResponse",
    Name = "RestApiResponse",
    FullName = "RestApiResponse.lua",
    IsRunnable = true,
    Data = [[
---@class Core.RestApi.RestApiResponse.Header
---@field Code Core.RestApi.StatusCodes

---@class Core.RestApi.RestApiResponse
---@field Headers Core.RestApi.RestApiResponse.Header | Dictionary<string, any>
---@field Body any
---@field WasSuccessfull boolean
---@overload fun(body: any, header: (Core.RestApi.RestApiResponse.Header | Dictionary<string, any>)?) : Core.RestApi.RestApiResponse
local RestApiResponse = {}

---@private
---@param body any
---@param header (Core.RestApi.RestApiResponse.Header | Dictionary<string, any>)?
function RestApiResponse:__init(body, header)
    self.Headers = header or {}
    self.Body = body
    if type(self.Headers.Code) == "number" then
        self.WasSuccessfull = self.Headers.Code < 300
    else
        self.WasSuccessfull = false
    end
end

---@return table
function RestApiResponse:ExtractData()
    return {
        Headers = self.Headers,
        Body = self.Body
    }
end

return Utils.Class.CreateClass(RestApiResponse, "Core.RestApi.RestApiResponse")
]]
}

PackageData.zRIGgCOY = {
    Namespace = "Net.Rest.RestApi.StatusCodes",
    Name = "StatusCodes",
    FullName = "StatusCodes.lua",
    IsRunnable = true,
    Data = [[
---@class Core.RestApi.StatusCodes
local StatusCodes = {
    StatusCode100Continue = 100,
    Status101SwitchingProtocols = 101,
    Status102Processing = 102,
    Status200OK = 200,
    Status201Created = 201,
    Status202Accepted = 202,
    Status203NonAuthoritative = 203,
    Status204NoContent = 204,
    Status205ResetContent = 205,
    Status206PartialContent = 206,
    Status207MultiStatus = 207,
    Status208AlreadyReported = 208,
    Status226IMUsed = 226,
    Status300MultipleChoices = 300,
    Status301MovedPermanently = 301,
    Status302Found = 302,
    Status303SeeOther = 303,
    Status304NotModified = 304,
    Status305UseProxy = 305,
    --- RFC 2616, removed
    Status306SwitchProxy = 306,
    Status307TemporaryRedirect = 307,
    Status308PermanentRedirect = 308,
    Status400BadRequest = 400,
    Status401Unauthorized = 401,
    Status402PaymentRequired = 402,
    Status403Forbidden = 403,
    Status404NotFound = 404,
    Status405MethodNotAllowed = 405,
    Status406NotAcceptable = 406,
    Status407ProxyAuthenticationRequired = 407,
    Status408RequestTimeout = 408,
    Status409Conflict = 409,
    Status410Gone = 410,
    Status411LengthRequired = 411,
    Status412PreconditionFailed = 412,
    --- RFC 2616, renamed
    Status413RequestEntityTooLarge = 413,
    --- RFC 7231
    Status413PayloadTooLarge = 413,
    --- RFC 2616, renamed
    Status414RequestUriTooLong = 414,
    --- RFC 7231
    Status414UriTooLong = 414,
    Status415UnsupportedMediaType = 415,
    --- RFC 2616, renamed
    Status416RequestedRangeNotSatisfiable = 416,
    --- RFC 7233
    Status416RangeNotSatisfiable = 416,
    Status417ExpectationFailed = 417,
    Status418ImATeapot = 418,
    --- Not defined in any RFC
    Status419AuthenticationTimeout = 419,
    Status421MisdirectedRequest = 421,
    Status422UnprocessableEntity = 422,
    Status423Locked = 423,
    Status424FailedDependency = 424,
    Status426UpgradeRequired = 426,
    Status428PreconditionRequired = 428,
    Status429TooManyRequests = 429,
    Status431RequestHeaderFieldsTooLarge = 431,
    Status451UnavailableForLegalReasons = 451,
    Status500InternalServerError = 500,
    Status501NotImplemented = 501,
    Status502BadGateway = 502,
    Status503ServiceUnavailable = 503,
    Status504GatewayTimeout = 504,
    Status505HttpVersionNotsupported = 505,
    Status506VariantAlsoNegotiates = 506,
    Status507InsufficientStorage = 507,
    Status508LoopDetected = 508,
    Status510NotExtended = 510,
    Status511NetworkAuthenticationRequired = 511,
}

return StatusCodes
]]
}

-- ########## Net.Rest.RestApi ########## --

-- ########## Net.Rest ########## --

return PackageData
