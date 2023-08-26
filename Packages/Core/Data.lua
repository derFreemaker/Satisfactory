local PackageData = {}

-- ########## Core ##########

-- ########## Core.Api ##########

-- ########## Core.Api.Client ##########

PackageData.PksKdJNx = {
    Namespace = "Core.Api.Client.ApiClient",
    Name = "ApiClient",
    FullName = "ApiClient.lua",
    IsRunnable = true,
    Data = function(...)
local ApiHelper = require("Core.Api.ApiHelper")
local ApiClient = {}
function ApiClient:ApiClient(serverIPAddress, serverPort, returnPort, netClient)
    self.ServerIPAddress = serverIPAddress
    self.ServerPort = serverPort
    self.ReturnPort = returnPort
    self.NetClient = netClient
    self.Logger = netClient.Logger:subLogger("ApiClient")
end
function ApiClient:request(request)
    self.NetClient:SendMessage(self.ServerIPAddress, self.ServerPort, "Rest-Request", { ReturnPort = self.ReturnPort }, request:ExtractData())
    local context = self.NetClient:WaitForEvent("Rest-Response", self.ReturnPort)
    local response = ApiHelper.NetworkContextToApiResponse(context)
    return response
end
return Utils.Class.CreateClass(ApiClient, "ApiClient")
end
}

-- ########## Core.Api.Client ########## --

-- ########## Core.Api.Server ##########

PackageData.RONgYwHx = {
    Namespace = "Core.Api.Server.ApiController",
    Name = "ApiController",
    FullName = "ApiController.lua",
    IsRunnable = true,
    Data = function(...)
local Task = require("Core.Task")
local ApiEndpoint = require("Core.Api.Server.ApiEndpoint")
local ApiHelper = require("Core.Api.ApiHelper")
local StatusCodes = require("Core.Api.StatusCodes")
local ApiResponseTemplates = require("Core.Api.Server.ApiResponseTemplates")
local ApiController = {}
function ApiController:ApiController(netPort)
    self.Endpoints = {}
    self.NetPort = netPort
    self.Logger = netPort.Logger:subLogger("ApiController")
    netPort:AddListener("Rest-Request", Task(self.onMessageRecieved, self))
end
function ApiController:onMessageRecieved(context)
    local request = ApiHelper.NetworkContextToApiRequest(context)
    self.Logger:LogDebug("recieved request on endpoint: '" .. request.Endpoint .. "'")
    local endpoint = self:GetEndpoint(request.Endpoint)
    if endpoint == nil then
        self.Logger:LogTrace("found no endpoint")
        if context.Header.ReturnPort then
            self.NetPort.NetClient:SendMessage(context.SenderIPAddress, context.Header.ReturnPort,
                "Rest-Response", nil, ApiResponseTemplates.NotFound("Unable to find endpoint"))
        end
        return
    end
    local response = endpoint:Execute(self.Logger:subLogger("Endpoint[".. request.Endpoint .."]"), request)
    if context.Header.ReturnPort then
        self.Logger:LogTrace("sending response...")
        self.NetPort.NetClient:SendMessage(context.SenderIPAddress, context.Header.ReturnPort, "Rest-Response", nil, response:ExtractData())
        self.Logger:LogTrace("sended response")
    else
        self.Logger:LogTrace("sending no response")
    end
    if response.Headers.Code == StatusCodes.Status200OK then
        self.Logger:LogDebug("request finished successfully")
    else
        self.Logger:LogDebug("request finished with status code: ".. response.Headers.Code .." with message: '".. response.Headers.Message .."'")
    end
end
function ApiController:GetEndpoint(endpointName)
    for name, endpoint in pairs(self.Endpoints) do
        if name == endpointName then
            return endpoint
        end
    end
    return nil
end
function ApiController:AddEndpoint(name, task)
    if self:GetEndpoint(name) ~= nil then
        error("Endpoint allready exists")
    end
    self.Endpoints[name] = ApiEndpoint(task)
    return self
end
return Utils.Class.CreateClass(ApiController, "ApiController")
end
}

PackageData.seyrvpeX = {
    Namespace = "Core.Api.Server.ApiEndpoint",
    Name = "ApiEndpoint",
    FullName = "ApiEndpoint.lua",
    IsRunnable = true,
    Data = function(...)
local ApiResponseTemplates = require("Core.Api.Server.ApiResponseTemplates")
local ApiEndpoint = {}
function ApiEndpoint:ApiEndpoint(task)
    self.task = task
end
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
end
}

PackageData.TtiCTjCx = {
    Namespace = "Core.Api.Server.ApiResponseTemplates",
    Name = "ApiResponseTemplates",
    FullName = "ApiResponseTemplates.lua",
    IsRunnable = true,
    Data = function(...)
local StatusCodes = require("Core.Api.StatusCodes")
local ApiResponse = require("Core.Api.ApiResponse")
local ApiResponseTemplates = {}
function ApiResponseTemplates.Ok(value)
    return ApiResponse({ Code = StatusCodes.Status200OK }, value)
end
function ApiResponseTemplates.BadRequest(message)
    return ApiResponse({ Code = StatusCodes.Status400BadRequest, Message = message })
end
function ApiResponseTemplates.NotFound(message)
    return ApiResponse({ Code = StatusCodes.Status404NotFound, Message = message })
end
function ApiResponseTemplates.InternalServerError(message)
    return ApiResponse({ Code = StatusCodes.Status500InternalServerError, Message = message })
end
return ApiResponseTemplates
end
}

-- ########## Core.Api.Server ########## --

PackageData.vISNqcZX = {
    Namespace = "Core.Api.ApiHelper",
    Name = "ApiHelper",
    FullName = "ApiHelper.lua",
    IsRunnable = true,
    Data = function(...)
local ApiRequest = require("Core.Api.ApiRequest")
local ApiResponse = require("Core.Api.ApiResponse")
local Helper = {}
function Helper.NetworkContextToApiResponse(context)
    return ApiResponse(context.Body.Headers, context.Body.Body)
end
function Helper.NetworkContextToApiRequest(context)
    return ApiRequest(context.Body.Endpoint, context.Body.Headers, context.Body.Body)
end
return Helper
end
}

PackageData.WXDYOWwx = {
    Namespace = "Core.Api.ApiRequest",
    Name = "ApiRequest",
    FullName = "ApiRequest.lua",
    IsRunnable = true,
    Data = function(...)
local ApiRequest = {}
function ApiRequest:ApiRequest(endpoint, headers, body)
    self.Endpoint = endpoint
    self.Headers = headers or {}
    self.Body = body
end
function ApiRequest:ExtractData()
    return {
        Endpoint = self.Endpoint,
        Headers = self.Headers,
        Body = self.Body
    }
end
return Utils.Class.CreateClass(ApiRequest, "ApiRequest")
end
}

PackageData.xnnklPUX = {
    Namespace = "Core.Api.ApiResponse",
    Name = "ApiResponse",
    FullName = "ApiResponse.lua",
    IsRunnable = true,
    Data = function(...)
local StatusCodes = require("Core.Api.StatusCodes")
local ApiResponse = {}
function ApiResponse:ApiResponse(header, body)
    self.Headers = header or {}
    self.Body = body
    self.WasSuccessfull = self.Headers.Code == StatusCodes.Status200OK
end
function ApiResponse:ExtractData()
    return {
        Headers = self.Headers,
        Body = self.Body
    }
end
return Utils.Class.CreateClass(ApiResponse, "ApiResponse")
end
}

PackageData.YCXvIIrx = {
    Namespace = "Core.Api.StatusCodes",
    Name = "StatusCodes",
    FullName = "StatusCodes.lua",
    IsRunnable = true,
    Data = function(...)
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

    Status413RequestEntityTooLarge = 413,

    Status413PayloadTooLarge = 413,

    Status414RequestUriTooLong = 414,

    Status414UriTooLong = 414,
    Status415UnsupportedMediaType = 415,

    Status416RequestedRangeNotSatisfiable = 416,

    Status416RangeNotSatisfiable = 416,
    Status417ExpectationFailed = 417,
    Status418ImATeapot = 418,

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
end
}

-- ########## Core.Api ########## --

-- ########## Core.Event ##########

PackageData.agsRDvly = {
    Namespace = "Core.Event.Event",
    Name = "Event",
    FullName = "Event.lua",
    IsRunnable = true,
    Data = function(...)
local Event = {}
function Event:Event()
    self.funcs = {}
    self.onceFuncs = {}
end
function Event:AddListener(task)
    table.insert(self.funcs, task)
    return self
end
Event.On = Event.AddListener
function Event:AddListenerOnce(task)
    table.insert(self.onceFuncs, task)
    return self
end
Event.Once = Event.AddListenerOnce
function Event:Trigger(logger, ...)
    for _, task in ipairs(self.funcs) do
        task:Execute(...)
        task:LogError(logger)
    end
    for _, task in ipairs(self.onceFuncs) do
        task:Execute(...)
        task:LogError(logger)
    end
    self.OnceFuncs = {}
end
function Event:TriggerDynamic(logger, args)
    for _, task in ipairs(self.funcs) do
        task:ExecuteDynamic(args)
        task:LogError(logger)
    end
    for _, task in ipairs(self.onceFuncs) do
        task:ExecuteDynamic(args)
        task:LogError(logger)
    end
    self.OnceFuncs = {}
end
function Event:Listeners()

    local permanentTask = {}
    for _, task in ipairs(self.funcs) do
        table.insert(permanentTask, task)
    end

    local onceTask = {}
    for _, task in ipairs(self.onceFuncs) do
        table.insert(onceTask, task)
    end
    return {
        Permanent = permanentTask,
        Once = onceTask
    }
end
function Event:__len()
    return #self.funcs + #self.onceFuncs
end
function Event:CopyTo(event)
    for _, listener in ipairs(self.funcs) do
        event:AddListener(listener)
    end
    for _, listener in ipairs(self.onceFuncs) do
        event:AddListenerOnce(listener)
    end
    return event
end
return Utils.Class.CreateClass(Event, "Event")
end
}

PackageData.CwccbpJY = {
    Namespace = "Core.Event.EventPullAdapter",
    Name = "EventPullAdapter",
    FullName = "EventPullAdapter.lua",
    IsRunnable = true,
    Data = function(...)
local Event = require("Core.Event.Event")
local EventPullAdapter = {}
function EventPullAdapter:onEventPull(eventPullData)

    local removeEvent = {}
    for name, event in pairs(self.events) do
        if name == eventPullData[1] then
            event:Trigger(self.logger, eventPullData)
        end
        if #event == 0 then
            table.insert(removeEvent, name)
        end
    end
    for _, name in ipairs(removeEvent) do
        self.events[name] = nil
    end
end
function EventPullAdapter:Initialize(logger)
    self.events = {}
    self.logger = logger
    self.OnEventPull = Event()
    return self
end
function EventPullAdapter:GetEvent(signalName)
    for name, event in pairs(self.events) do
        if name == signalName then
            return event
        end
    end
    local event = Event()
    self.events[signalName] = event
    return event
end
function EventPullAdapter:AddListener(signalName, task)
    local event = self:GetEvent(signalName)
    event:AddListener(task)
    return self
end
function EventPullAdapter:AddListenerOnce(signalName, task)
    local event = self:GetEvent(signalName)
    event:AddListenerOnce(task)
    return self
end
function EventPullAdapter:Wait(timeout)

    local eventPullData = nil
    if timeout == nil then
        eventPullData = table.pack(event.pull())
    else
        eventPullData = table.pack(event.pull(timeout))
    end
    if not eventPullData or #eventPullData == 0 then
        return
    end
    self.logger:LogDebug("signalName: '".. eventPullData[1] .."' was recieved")
    self.OnEventPull:Trigger(self.logger, eventPullData)
    self:onEventPull(eventPullData)
end
function EventPullAdapter:Run()
    self.logger:LogDebug("## started event pull loop ##")
    while true do
        self.logger:LogTrace("## waiting for event pull ##")
        self:Wait()
    end
end
return EventPullAdapter
end
}

-- ########## Core.Event ########## --

-- ########## Core.Net ##########

PackageData.EaxyWcDY = {
    Namespace = "Core.Net.NetworkClient",
    Name = "NetworkClient",
    FullName = "NetworkClient.lua",
    IsRunnable = true,
    Data = function(...)
local Json = require("Core.Json")
local EventPullAdapter = require("Core.Event.EventPullAdapter")
local Task = require("Core.Task")
local NetworkPort = require("Core.Net.NetworkPort")
local NetworkContext = require("Core.Net.NetworkContext")
local NetworkClient = {}
function NetworkClient:NetworkClient(logger, networkCard)
    if networkCard == nil then
        networkCard = computer.getPCIDevices(findClass("NetworkCard"))[1]
        if networkCard == nil then
            error("no networkCard was found")
        end
    end
    self.Logger = logger
    self.ports = {}
    self.networkCard = networkCard
    event.listen(networkCard)
    EventPullAdapter:AddListener("NetworkMessage", Task(self.networkMessageRecieved, self))
end
function NetworkClient:networkMessageRecieved(data)
    local context = NetworkContext(data)
    self.Logger:LogDebug("recieved network message with event: '" .. context.EventName .. "' on port: '" .. context.Port .. "'")
    for i, port in pairs(self.ports) do
        if port.Port == context.Port or port.Port == "all" then
            port:Execute(context)
        end
        if #port.Events == 0 then
            port:ClosePort()
            self.ports[i] = nil
        end
    end
end
function NetworkClient:GetNetworkPort(port)
    for portNumber, networkPort in pairs(self.ports) do
        if portNumber == port then
            return networkPort
        end
    end
    return nil
end
function NetworkClient:AddListener(onRecivedEventName, onRecivedPort, listener)
    onRecivedEventName = onRecivedEventName or "all"
    onRecivedPort = onRecivedPort or "all"
    local networkPort = self:GetNetworkPort(onRecivedPort) or self:CreateNetworkPort(onRecivedPort)
    networkPort:AddListener(onRecivedEventName, listener)
    return self
end
NetworkClient.On = NetworkClient.AddListener
function NetworkClient:AddListenerOnce(onRecivedEventName, onRecivedPort, listener)
    onRecivedEventName = onRecivedEventName or "all"
    onRecivedPort = onRecivedPort or "all"
    local networkPort = self:GetNetworkPort(onRecivedPort) or self:CreateNetworkPort(onRecivedPort)
    networkPort:AddListener(onRecivedEventName, listener)
    return self
end
NetworkClient.Once = NetworkClient.AddListenerOnce
function NetworkClient:CreateNetworkPort(port)
    port = port or "all"
    local networkPort = self:GetNetworkPort(port)
    if networkPort ~= nil then
        return networkPort
    end
    networkPort = NetworkPort(port, self.Logger:subLogger("NetworkPort[".. port .."]"), self)
    self.ports[port] = networkPort
    return networkPort
end
function NetworkClient:WaitForEvent(eventName, port)
    local result

    local function set(context)
        result = context
    end
    self:AddListenerOnce(eventName, port, Task(set))
    repeat
        EventPullAdapter:Wait()
    until result ~= nil
    return result
end
function NetworkClient:OpenPort(port)
    self.networkCard:open(port)
end
function NetworkClient:ClosePort(port)
    self.networkCard:close(port)
end
function NetworkClient:CloseAllPorts()
    self.networkCard:closeAll()
end
function NetworkClient:SendMessage(ipAddress, port, eventName, header, body)
    self.networkCard:send(ipAddress, port, eventName, Json.encode(header or {}), Json.encode(body))
end
function NetworkClient:BroadCastMessage(port, eventName, header, body)
    self.networkCard:broadcast(port, eventName, Json.encode(header or {}), Json.encode(body))
end
return Utils.Class.CreateClass(NetworkClient, "NetworkClient")
end
}

PackageData.fphJtVby = {
    Namespace = "Core.Net.NetworkContext",
    Name = "NetworkContext",
    FullName = "NetworkContext.lua",
    IsRunnable = true,
    Data = function(...)
local Json = require("Core.Json")
local NetworkContext = {}
function NetworkContext:NetworkContext(data)
    self.SignalName = data[1]
    self.SignalSender = data[2]
    self.SenderIPAddress = data[3]
    self.Port = data[4]
    self.EventName = data[5]
    self.Header = Json.decode(data[6])
    self.Body = Json.decode(data[7])
end
return Utils.Class.CreateClass(NetworkContext, "NetworkContext")
end
}

PackageData.GFSURPyY = {
    Namespace = "Core.Net.NetworkPort",
    Name = "NetworkPort",
    FullName = "NetworkPort.lua",
    IsRunnable = true,
    Data = function(...)
local Event = require("Core.Event.Event")
local NetworkPort = {}
function NetworkPort:NetworkPort(port, logger, netClient)
    self.Port = port
    self.Events = {}
    self.Logger = logger
    self.NetClient = netClient
end
function NetworkPort:Execute(context)
    self.Logger:LogTrace("got triggered with event: '".. context.EventName .."'")
    for name, event in pairs(self.Events) do
        if name == context.EventName or name == "all" then
            event:Trigger(self.Logger, context)
        end
        if #event == 0 then
            self.Events[name] = nil
        end
    end
end
function NetworkPort:GetEvent(eventName)
    for name, event in pairs(self.Events) do
        if name == eventName then
            return event
        end
    end
    local event = Event()
    self.Events[eventName] = event
    return event
end
function NetworkPort:AddListener(onRecivedEventName, listener)
    local event = self:GetEvent(onRecivedEventName)
    event:AddListener(listener)
    return self
end
NetworkPort.On = NetworkPort.AddListener
function NetworkPort:AddListenerOnce(onRecivedEventName, listener)
    local event = self:GetEvent(onRecivedEventName)
    event:AddListenerOnce(listener)
    return self
end
NetworkPort.Once = NetworkPort.AddListenerOnce
function NetworkPort:OpenPort()
    local port = self.Port
    if type(port) == "number" then
        self.NetClient:OpenPort(port)
    end
end
function NetworkPort:ClosePort()
    local port = self.Port
    if type(port) == "number" then
        self.NetClient:ClosePort(port)
    end
end
return Utils.Class.CreateClass(NetworkPort, "NetworkPort")
end
}

-- ########## Core.Net ########## --

PackageData.hUCfoIVy = {
    Namespace = "Core.Json",
    Name = "Json",
    FullName = "Json.lua",
    IsRunnable = true,
    Data = function(...)
local json = { _version = "0.1.2" }
local encode
local escape_char_map = {
    ["\\"] = "\\",
    ["\""] = "\"",
    ["\b"] = "b",
    ["\f"] = "f",
    ["\n"] = "n",
    ["\r"] = "r",
    ["\t"] = "t",
}
local escape_char_map_inv = { ["/"] = "/" }
for k, v in pairs(escape_char_map) do
    escape_char_map_inv[v] = k
end
local function escape_char(c)
    return "\\" .. (escape_char_map[c] or string.format("u%04x", c:byte()))
end
local function encode_nil(val)
    return "null"
end
local function encode_table(val, stack)
    local res = {}
    stack = stack or {}

    if stack[val] then error("circular reference") end
    stack[val] = true
    if rawget(val, 1) ~= nil or next(val) == nil then

        local n = 0
        for k in pairs(val) do
            if type(k) ~= "number" then
                error("invalid table: mixed or invalid key types")
            end
            n = n + 1
        end
        if n ~= #val then
            error("invalid table: sparse array")
        end

        for i, v in ipairs(val) do
            table.insert(res, encode(v, stack))
        end
        stack[val] = nil
        return "[" .. table.concat(res, ",") .. "]"
    else

        for k, v in pairs(val) do
            if type(k) ~= "string" then
                error("invalid table: mixed or invalid key types")
            end
            table.insert(res, encode(k, stack) .. ":" .. encode(v, stack))
        end
        stack[val] = nil
        return "{" .. table.concat(res, ",") .. "}"
    end
end
local function encode_string(val)
    return '"' .. val:gsub('[%z\1-\31\\"]', escape_char) .. '"'
end
local function encode_number(val)

    if val ~= val or val <= -math.huge or val >= math.huge then
        error("unexpected number value '" .. tostring(val) .. "'")
    end
    return string.format("%.14g", val)
end
local type_func_map = {
    ["nil"] = encode_nil,
    ["table"] = encode_table,
    ["string"] = encode_string,
    ["number"] = encode_number,
    ["boolean"] = tostring,
}
encode = function(val, stack)
    local t = type(val)
    local f = type_func_map[t]
    if f then
        return f(val, stack)
    end
    error("unexpected type '" .. t .. "'")
end
function json.encode(val)
    return (encode(val))
end
local parse
local function create_set(...)
    local res = {}
    for i = 1, select("#", ...) do
        res[select(i, ...)] = true
    end
    return res
end
local space_chars  = create_set(" ", "\t", "\r", "\n")
local delim_chars  = create_set(" ", "\t", "\r", "\n", "]", "}", ",")
local escape_chars = create_set("\\", "/", '"', "b", "f", "n", "r", "t", "u")
local literals     = create_set("true", "false", "null")
local literal_map  = {
    ["true"] = true,
    ["false"] = false,
    ["null"] = nil,
}
local function next_char(str, idx, set, negate)
    for i = idx, #str do
        if set[str:sub(i, i)] ~= negate then
            return i
        end
    end
    return #str + 1
end
local function decode_error(str, idx, msg)
    local line_count = 1
    local col_count = 1
    for i = 1, idx - 1 do
        col_count = col_count + 1
        if str:sub(i, i) == "\n" then
            line_count = line_count + 1
            col_count = 1
        end
    end
    error(string.format("%s at line %d col %d", msg, line_count, col_count))
end
local function codepoint_to_utf8(n)

    local f = math.floor
    if n <= 0x7f then
        return string.char(n)
    elseif n <= 0x7ff then
        return string.char(f(n / 64) + 192, n % 64 + 128)
    elseif n <= 0xffff then
        return string.char(f(n / 4096) + 224, f(n % 4096 / 64) + 128, n % 64 + 128)
    elseif n <= 0x10ffff then
        return string.char(f(n / 262144) + 240, f(n % 262144 / 4096) + 128,
            f(n % 4096 / 64) + 128, n % 64 + 128)
    end
    error(string.format("invalid unicode codepoint '%x'", n))
end
local function parse_unicode_escape(s)
    local n1 = tonumber(s:sub(1, 4), 16)
    local n2 = tonumber(s:sub(7, 10), 16)

    if n2 then
        return codepoint_to_utf8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000)
    else
        return codepoint_to_utf8(n1)
    end
end
local function parse_string(str, i)
    local res = ""
    local j = i + 1
    local k = j
    while j <= #str do
        local x = str:byte(j)
        if x < 32 then
            decode_error(str, j, "control character in string")
        elseif x == 92 then
            res = res .. str:sub(k, j - 1)
            j = j + 1
            local c = str:sub(j, j)
            if c == "u" then
                local hex = str:match("^[dD][89aAbB]%x%x\\u%x%x%x%x", j + 1)
                    or str:match("^%x%x%x%x", j + 1)
                    or decode_error(str, j - 1, "invalid unicode escape in string")
                res = res .. parse_unicode_escape(hex)
                j = j + #hex
            else
                if not escape_chars[c] then
                    decode_error(str, j - 1, "invalid escape char '" .. c .. "' in string")
                end
                res = res .. escape_char_map_inv[c]
            end
            k = j + 1
        elseif x == 34 then
            res = res .. str:sub(k, j - 1)
            return res, j + 1
        end
        j = j + 1
    end
    decode_error(str, i, "expected closing quote for string")
end
local function parse_number(str, i)
    local x = next_char(str, i, delim_chars)
    local s = str:sub(i, x - 1)
    local n = tonumber(s)
    if not n then
        decode_error(str, i, "invalid number '" .. s .. "'")
    end
    return n, x
end
local function parse_literal(str, i)
    local x = next_char(str, i, delim_chars)
    local word = str:sub(i, x - 1)
    if not literals[word] then
        decode_error(str, i, "invalid literal '" .. word .. "'")
    end
    return literal_map[word], x
end
local function parse_array(str, i)
    local res = {}
    local n = 1
    i = i + 1
    while 1 do
        local x
        i = next_char(str, i, space_chars, true)

        if str:sub(i, i) == "]" then
            i = i + 1
            break
        end

        x, i = parse(str, i)
        res[n] = x
        n = n + 1

        i = next_char(str, i, space_chars, true)
        local chr = str:sub(i, i)
        i = i + 1
        if chr == "]" then break end
        if chr ~= "," then decode_error(str, i, "expected ']' or ','") end
    end
    return res, i
end
local function parse_object(str, i)
    local res = {}
    i = i + 1
    while 1 do
        local key, val
        i = next_char(str, i, space_chars, true)

        if str:sub(i, i) == "}" then
            i = i + 1
            break
        end

        if str:sub(i, i) ~= '"' then
            decode_error(str, i, "expected string for key")
        end
        key, i = parse(str, i)

        i = next_char(str, i, space_chars, true)
        if str:sub(i, i) ~= ":" then
            decode_error(str, i, "expected ':' after key")
        end
        i = next_char(str, i + 1, space_chars, true)

        val, i = parse(str, i)

        res[key] = val

        i = next_char(str, i, space_chars, true)
        local chr = str:sub(i, i)
        i = i + 1
        if chr == "}" then break end
        if chr ~= "," then decode_error(str, i, "expected '}' or ','") end
    end
    return res, i
end
local char_func_map = {
    ['"'] = parse_string,
    ["0"] = parse_number,
    ["1"] = parse_number,
    ["2"] = parse_number,
    ["3"] = parse_number,
    ["4"] = parse_number,
    ["5"] = parse_number,
    ["6"] = parse_number,
    ["7"] = parse_number,
    ["8"] = parse_number,
    ["9"] = parse_number,
    ["-"] = parse_number,
    ["t"] = parse_literal,
    ["f"] = parse_literal,
    ["n"] = parse_literal,
    ["["] = parse_array,
    ["{"] = parse_object,
}
parse = function(str, idx)
    local chr = str:sub(idx, idx)
    local f = char_func_map[chr]
    if f then
        return f(str, idx)
    end
    decode_error(str, idx, "unexpected character '" .. chr .. "'")
end
function json.decode(str)
    if type(str) ~= "string" then
        error("expected argument of type string, got " .. type(str))
    end
    local res, idx = parse(str, next_char(str, 1, space_chars, true))
    idx = next_char(str, idx, space_chars, true)
    if idx <= #str then
        decode_error(str, idx, "trailing garbage")
    end
    return res
end
return json
end
}

PackageData.JjmrMBtY = {
    Namespace = "Core.Logger",
    Name = "Logger",
    FullName = "Logger.lua",
    IsRunnable = true,
    Data = function(...)
local Event = require("Core.Event.Event")
local Logger = {}
local function tableToLineTree(node, maxLevel, properties, level, padding)
    padding = padding or '     '
    maxLevel = maxLevel or 5
    level = level or 1
    local lines = {}
    if type(node) == 'table' then
        local keys = {}
        if type(properties) == 'string' then
            local propSet = {}
            for p in string.gmatch(properties, "%b{}") do
                local propName = string.sub(p, 2, -2)
                for k in string.gmatch(propName, "[^,%s]+") do
                    propSet[k] = true
                end
            end
            for k in pairs(node) do
                if propSet[k] then
                    keys[#keys + 1] = k
                end
            end
        else
            for k in pairs(node) do
                if not properties or properties[k] then
                    keys[#keys + 1] = k
                end
            end
        end
        table.sort(keys)
        for i, k in ipairs(keys) do
            local line = ''
            if i == #keys then
                line = padding .. '└── ' .. tostring(k)
            else
                line = padding .. '├── ' .. tostring(k)
            end
            table.insert(lines, line)
            if level < maxLevel then

                local childLines = tableToLineTree(node[k], maxLevel, properties, level + 1, padding .. (i == #keys and '    ' or '│   '))
                for _, l in ipairs(childLines) do
                    table.insert(lines, l)
                end
            elseif i == #keys then
                table.insert(lines, padding .. '└── ...')
            end
        end
    else
        table.insert(lines, padding .. tostring(node))
    end
    return lines
end
function Logger:Logger(name, logLevel, onLog, onClear)
    self.LogLevel = logLevel
    self.Name = (string.gsub(name, " ", "_") or "")
    self.OnLog = onLog or Event()
    self.OnClear = onClear or Event()
end
function Logger:subLogger(name)
    name = self.Name .. "." .. name
    local logger = Logger(name, self.LogLevel)
    return self:CopyListenersTo(logger)
end
function Logger:CopyListenersTo(logger)
    self.OnLog:CopyTo(logger.OnLog)
    self.OnClear:CopyTo(logger.OnClear)
    return logger
end
function Logger:Log(message, logLevel)
    if logLevel < self.LogLevel then
        return
    end
    message = "[" .. self.Name .. "] " .. message
    self.OnLog:Trigger(nil, message)
end
function Logger:LogTable(t, logLevel, maxLevel, properties)
    if logLevel < self.LogLevel then
        return
    end
    if t == nil or type(t) ~= "table" then return end
    for _, line in ipairs(tableToLineTree(t, maxLevel, properties)) do
        self:Log(line, logLevel)
    end
end
function Logger:Clear()
    self.OnClear:Trigger()
end
function Logger:FreeLine(logLevel)
    if logLevel < self.LogLevel then
        return
    end
    self.OnLog:Trigger(self, "")
end
function Logger:LogTrace(message)
    if message == nil then return end
    self:Log("TRACE " .. tostring(message), 0)
end
function Logger:LogDebug(message)
    if message == nil then return end
    self:Log("DEBUG " .. tostring(message), 1)
end
function Logger:LogInfo(message)
    if message == nil then return end
    self:Log("INFO " .. tostring(message), 2)
end
function Logger:LogWarning(message)
    if message == nil then return end
    self:Log("WARN " .. tostring(message), 3)
end
function Logger:LogError(message)
    if message == nil then return end
    self:Log("ERROR " .. tostring(message), 4)
end
function Logger:setErrorLogger()
    _G.__errorLogger = self
end
return Utils.Class.CreateClass(Logger, "Logger")
end
}

PackageData.kyXCjvQy = {
    Namespace = "Core.Task",
    Name = "Task",
    FullName = "Task.lua",
    IsRunnable = true,
    Data = function(...)
local Task = {}
function Task:invokeFunc(...)
    if self.parent then
        return coroutine.yield(self.func(self.parent, ...))
    end
    return coroutine.yield(self.func(...))
end
function Task:Task(func, parent)
    self.func = func
    self.parent = parent
end
function Task:IsSuccess()
    return self.success
end
function Task:GetResults()
    return table.unpack(self.results)
end
function Task:GetResultsArray()
    return self.results
end
function Task:GetErrorObject()
    return self.errorObject
end
local function extractData(success, ...)
    return success, { ... }
end
function Task:Execute(...)
    self.thread = coroutine.create(self.invokeFunc)
    self.success, self.results = extractData(coroutine.resume(self.thread, self, ...))
    self.noError, self.errorObject = coroutine.close(self.thread)
    return table.unpack(self.results)
end
function Task:ExecuteDynamic(args)
    self.thread = coroutine.create(self.invokeFunc)
    self.success, self.results = extractData(coroutine.resume(self.thread, self, table.unpack(args)))
    self.noError, self.errorObject = coroutine.close(self.thread)
    return self.results
end
function Task:LogError(logger)
    if not self.noError and logger then
        logger:LogError("execution error: \n" .. debug.traceback(self.thread, self.errorObject) .. debug.traceback():sub(17))
    end
end
return Utils.Class.CreateClass(Task, "Task")
end
}

-- ########## Core ########## --

return PackageData
