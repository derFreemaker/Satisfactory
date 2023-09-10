local PackageData = {}

-- ########## Core ##########

-- ########## Core.Event ##########

PackageData.oVIzFPpX = {
    Namespace = "Core.Event.Event",
    Name = "Event",
    FullName = "Event.lua",
    IsRunnable = true,
    Data = [[
---@class Core.Event : object
---@field private funcs Core.Task[]
---@field private onceFuncs Core.Task[]
---@operator len() : integer
---@overload fun() : Core.Event
local Event = {}

---@private
function Event:__init()
    self.funcs = {}
    self.onceFuncs = {}
end

---@param task Core.Task
---@return Core.Event
function Event:AddListener(task)
    table.insert(self.funcs, task)
    return self
end
Event.On = Event.AddListener

---@param task Core.Task
---@return Core.Event
function Event:AddListenerOnce(task)
    table.insert(self.onceFuncs, task)
    return self
end
Event.Once = Event.AddListenerOnce

---@param logger Core.Logger?
---@param ... any
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

---@param logger Core.Logger?
---@param args table
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

---@alias Core.Event.Mode
---|"Permanent"
---|"Once"

---@return Dictionary<Core.Event.Mode, Core.Task[]>
function Event:Listeners()
    ---@type Core.Task[]
    local permanentTask = {}
    for _, task in ipairs(self.funcs) do
        table.insert(permanentTask, task)
    end

    ---@type Core.Task[]
    local onceTask = {}
    for _, task in ipairs(self.onceFuncs) do
        table.insert(onceTask, task)
    end
    return {
        Permanent = permanentTask,
        Once = onceTask
    }
end

---@private
---@return integer count
function Event:__len()
    return #self.funcs + #self.onceFuncs
end

---@param event Core.Event
---@return Core.Event event
function Event:CopyTo(event)
    for _, listener in ipairs(self.funcs) do
        event:AddListener(listener)
    end
    for _, listener in ipairs(self.onceFuncs) do
        event:AddListenerOnce(listener)
    end
    return event
end

return Utils.Class.CreateClass(Event, "Core.Event")
]]
}

PackageData.PksKdJNx = {
    Namespace = "Core.Event.EventPullAdapter",
    Name = "EventPullAdapter",
    FullName = "EventPullAdapter.lua",
    IsRunnable = true,
    Data = [[
local Event = require("Core.Event.Event")

---@class Core.EventPullAdapter
---@field private events Dictionary<string, Core.Event>
---@field private logger Core.Logger
---@field OnEventPull Core.Event
local EventPullAdapter = {}

---@private
---@param eventPullData any[]
function EventPullAdapter:onEventPull(eventPullData)
    ---@type string[]
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

---@param logger Core.Logger
---@return Core.EventPullAdapter
function EventPullAdapter:Initialize(logger)
    self.events = {}
    self.logger = logger
    self.OnEventPull = Event()
    return self
end

---@param signalName string
---@return Core.Event
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

---@param signalName string
---@param task Core.Task
function EventPullAdapter:AddListener(signalName, task)
    local event = self:GetEvent(signalName)
    event:AddListener(task)
    return self
end

---@param signalName string
---@param task Core.Task
function EventPullAdapter:AddListenerOnce(signalName, task)
    local event = self:GetEvent(signalName)
    event:AddListenerOnce(task)
    return self
end

---@param timeout number?
---@return boolean gotEvent
function EventPullAdapter:Wait(timeout)
    self.logger:LogTrace("## waiting for event pull ##")
    ---@type table?
    local eventPullData = nil
    if timeout == nil then
        eventPullData = { event.pull() }
    else
        eventPullData = { event.pull(timeout) }
    end
    if #eventPullData == 0 then
        return false
    end
    self.logger:LogDebug("event with signalName: '".. eventPullData[1] .."' was recieved")
    self.OnEventPull:Trigger(self.logger, eventPullData)
    self:onEventPull(eventPullData)
    return true
end

function EventPullAdapter:Run()
    self.logger:LogDebug("## started event pull loop ##")
    while true do
        self:Wait()
    end
end

return EventPullAdapter
]]
}

-- ########## Core.Event ########## --

-- ########## Core.Net ##########

PackageData.RONgYwHx = {
    Namespace = "Core.Net.NetworkClient",
    Name = "NetworkClient",
    FullName = "NetworkClient.lua",
    IsRunnable = true,
    Data = [[
local Json = require("Core.Json")
local EventPullAdapter = require("Core.Event.EventPullAdapter")
local Task = require("Core.Task")
local NetworkPort = require("Core.Net.NetworkPort")
local NetworkContext = require("Core.Net.NetworkContext")

---@class Core.Net.NetworkClient : object
---@field private id string?
---@field private Logger Core.Logger
---@field private ports Dictionary<integer | "all", Core.Net.NetworkPort>
---@field private networkCard FicsIt_Networks.Components.FINComputerMod.NetworkCard
---@overload fun(logger: Core.Logger, networkCard: FicsIt_Networks.Components.FINComputerMod.NetworkCard?) : Core.Net.NetworkClient
local NetworkClient = {}

---@private
---@param logger Core.Logger
---@param networkCard FicsIt_Networks.Components.FINComputerMod.NetworkCard?
function NetworkClient:__init(logger, networkCard)
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

---@return string
function NetworkClient:GetId()
    if self.id then
        return self.id
    end

    local splittedPrint = Utils.String.Split(tostring(self.networkCard), " ")
    self.id = splittedPrint[#splittedPrint]
    return self.id
end

---@private
---@param data any[]
function NetworkClient:networkMessageRecieved(data)
    local context = NetworkContext(data)
    self.Logger:LogDebug("recieved network message with event: '" .. context.EventName .. "' on port: '" .. context.Port .. "'")
    for i, port in pairs(self.ports) do
        if port.Port == context.Port or port.Port == "all" then
            port:Execute(context)
        end
        if Utils.Table.Count(port:GetEvents()) == 0 then
            port:ClosePort()
            self.ports[i] = nil
        end
    end
end

---@protected
---@param port integer | "all"
function NetworkClient:GetNetworkPort(port)
    for portNumber, networkPort in pairs(self.ports) do
        if portNumber == port then
            return networkPort
        end
    end
    return nil
end

---@param onRecivedEventName (string | "all")?
---@param onRecivedPort (integer | "all")?
---@param listener Core.Task
---@return Core.Net.NetworkPort
function NetworkClient:AddListener(onRecivedEventName, onRecivedPort, listener)
    onRecivedEventName = onRecivedEventName or "all"
    onRecivedPort = onRecivedPort or "all"

    local networkPort = self:GetNetworkPort(onRecivedPort) or self:CreateNetworkPort(onRecivedPort)
    networkPort:AddListener(onRecivedEventName, listener)
    return networkPort
end
NetworkClient.On = NetworkClient.AddListener

---@param onRecivedEventName (string | "all")?
---@param onRecivedPort (integer | "all")?
---@param listener Core.Task
---@return Core.Net.NetworkPort
function NetworkClient:AddListenerOnce(onRecivedEventName, onRecivedPort, listener)
    onRecivedEventName = onRecivedEventName or "all"
    onRecivedPort = onRecivedPort or "all"

    local networkPort = self:GetNetworkPort(onRecivedPort) or self:CreateNetworkPort(onRecivedPort)
    networkPort:AddListener(onRecivedEventName, listener)
    return networkPort
end
NetworkClient.Once = NetworkClient.AddListenerOnce

---@param port (integer | "all")?
---@return Core.Net.NetworkPort
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

---@param eventName string | "all"
---@param port integer | "all"
---@param timeout number?
---@return Core.Net.NetworkContext?
function NetworkClient:WaitForEvent(eventName, port, timeout)
    self.Logger:LogDebug("waiting for event: '".. eventName .."' on port: ".. port)
    local result
    ---@param context Core.Net.NetworkContext
    local function set(context)
        result = context
    end
    self:AddListenerOnce(eventName, port, Task(set)):OpenPort()
    repeat
        if not EventPullAdapter:Wait(timeout) then
            break
        end
    until result ~= nil
    return result
end

---@param port integer
function NetworkClient:OpenPort(port)
    self.networkCard:open(port)
    self.Logger:LogTrace("opened Port: " .. port)
end

---@param port integer
function NetworkClient:ClosePort(port)
    self.networkCard:close(port)
    self.Logger:LogTrace("closed Port: " .. port)
end

function NetworkClient:CloseAllPorts()
    self.networkCard:closeAll()
    self.Logger:LogTrace("closed all Ports")
end

---@param ipAddress string
---@param port integer
---@param eventName string
---@param body any
---@param header Dictionary<string, any>?
function NetworkClient:SendMessage(ipAddress, port, eventName, body, header)
    self.networkCard:send(ipAddress, port, eventName, Json.encode(body), Json.encode(header or {}))
end

---@param port integer
---@param eventName string
---@param body any
---@param header Dictionary<string, any>?
function NetworkClient:BroadCastMessage(port, eventName, body, header)
    self.networkCard:broadcast(port, eventName, Json.encode(body), Json.encode(header or {}))
end

return Utils.Class.CreateClass(NetworkClient, "Core.Net.NetworkClient")
]]
}

PackageData.seyrvpeX = {
    Namespace = "Core.Net.NetworkContext",
    Name = "NetworkContext",
    FullName = "NetworkContext.lua",
    IsRunnable = true,
    Data = [[
local Json = require("Core.Json")
local RestApiRequest = require("Core.RestApi.RestApiRequest")
local RestApiResponse = require("Core.RestApi.RestApiResponse")

---@class Core.Net.NetworkContext : object
---@field SignalName string
---@field SignalSender FicsIt_Networks.Components.Object
---@field SenderIPAddress string
---@field Port integer
---@field EventName string
---@field Header Dictionary<string, any>
---@field Body any
---@overload fun(data: any[]) : Core.Net.NetworkContext
local NetworkContext = {}

---@private
---@param data any[]
function NetworkContext:__init(data)
    self.SignalName = data[1]
    self.SignalSender = data[2]
    self.SenderIPAddress = data[3]
    self.Port = data[4]
    self.EventName = data[5]
    self.Header = Json.decode(data[7] or "null")
    self.Body = Json.decode(data[6] or "null")
end

---@return Core.RestApi.RestApiRequest
function NetworkContext:ToApiRequest()
    return RestApiRequest(self.Body.Method, self.Body.Endpoint, self.Body.Body, self.Body.Headers)
end

---@return Core.RestApi.RestApiResponse
function NetworkContext:ToApiResponse()
    return RestApiResponse(self.Body.Headers, self.Body.Body)
end

return Utils.Class.CreateClass(NetworkContext, "Core.Net.NetworkContext")
]]
}

PackageData.TtiCTjCx = {
    Namespace = "Core.Net.NetworkPort",
    Name = "NetworkPort",
    FullName = "NetworkPort.lua",
    IsRunnable = true,
    Data = [[
local Event = require("Core.Event.Event")

---@class Core.Net.NetworkPort : object
---@field Port integer | "all"
---@field private events Dictionary<string, Core.Event>
---@field private netClient Core.Net.NetworkClient
---@field private logger Core.Logger
---@overload fun(port: integer | "all", logger: Core.Logger, netClient: Core.Net.NetworkClient) : Core.Net.NetworkPort
local NetworkPort = {}

---@private
---@param port integer | "all"
---@param logger Core.Logger
---@param netClient Core.Net.NetworkClient
function NetworkPort:__init(port, logger, netClient)
    self.Port = port
    self.events = {}
    self.logger = logger
    self.netClient = netClient
end

---@return Dictionary<string, Core.Event>
function NetworkPort:GetEvents()
    return Utils.Table.Copy(self.events)
end

---@return Core.Net.NetworkClient
function NetworkPort:GetNetClient()
    return self.netClient
end

---@param context Core.Net.NetworkContext
function NetworkPort:Execute(context)
    self.logger:LogTrace("got triggered with event: '".. context.EventName .."'")
    for name, event in pairs(self.events) do
        if name == context.EventName or name == "all" then
            event:Trigger(self.logger, context)
        end
        if #event == 0 then
            self.events[name] = nil
        end
    end
end

---@protected
---@param eventName string | "all"
---@return Core.Event
function NetworkPort:GetEvent(eventName)
    for name, event in pairs(self.events) do
        if name == eventName then
            return event
        end
    end
    local event = Event()
    self.events[eventName] = event
    return event
end

---@param onRecivedEventName string | "all"
---@param listener Core.Task
---@return Core.Net.NetworkPort
function NetworkPort:AddListener(onRecivedEventName, listener)
    local event = self:GetEvent(onRecivedEventName)
    event:AddListener(listener)
    return self
end
NetworkPort.On = NetworkPort.AddListener

---@param onRecivedEventName string | "all"
---@param listener Core.Task
---@return Core.Net.NetworkPort
function NetworkPort:AddListenerOnce(onRecivedEventName, listener)
    local event = self:GetEvent(onRecivedEventName)
    event:AddListenerOnce(listener)
    return self
end
NetworkPort.Once = NetworkPort.AddListenerOnce

---@param eventName string
---@param timeout number?
---@return Core.Net.NetworkContext?
function NetworkPort:WaitForEvent(eventName, timeout)
    return self.netClient:WaitForEvent(eventName, self.Port, timeout)
end

function NetworkPort:OpenPort()
    local port = self.Port
    if type(port) == "number" then
        self.netClient:OpenPort(port)
    end
end

function NetworkPort:ClosePort()
    local port = self.Port
    if type(port) == "number" then
        self.netClient:ClosePort(port)
    end
end

---@param ipAddress string
---@param eventName string
---@param body any
---@param header Dictionary<string, any>?
function NetworkPort:SendMessage(ipAddress, eventName, body, header)
    local port = self.Port
    if port == "all" then
        error("Unable to send a message over all ports")
    end
    ---@cast port integer
    self.netClient:SendMessage(ipAddress, port, eventName, body, header)
end

---@param eventName string
---@param body any
---@param header Dictionary<string, any>?
function NetworkPort:BroadCastMessage(eventName, body, header)
    local port = self.Port
    if port == "all" then
        error("Unable to broadcast a message over all ports")
    end
    ---@cast port integer
    self.netClient:BroadCastMessage(port, eventName, body, header)
end

return Utils.Class.CreateClass(NetworkPort, "Core.Net.NetworkPort")
]]
}

-- ########## Core.Net ########## --

-- ########## Core.RestApi ##########

-- ########## Core.RestApi.Client ##########

PackageData.xnnklPUX = {
    Namespace = "Core.RestApi.Client.RestApiNetworkClient",
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
    self.NetClient:SendMessage(self.ServerIPAddress, self.ServerPort, "Rest-Request", { ReturnPort = self.ReturnPort }, request:ExtractData())
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

-- ########## Core.RestApi.Client ########## --

-- ########## Core.RestApi.Server ##########

PackageData.zRIGgCOY = {
    Namespace = "Core.RestApi.Server.RestApiController",
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
                "Rest-Response", nil, RestApiResponseTemplates.NotFound("Unable to find endpoint"):ExtractData())
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
    self.Endpoints[method .. "__" .. name] = RestApiEndpoint(task, self.logger:subLogger("RestApiEndpoint[" .. name .. "]"))
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

PackageData.agsRDvly = {
    Namespace = "Core.RestApi.Server.RestApiEndpoint",
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
]]
}

PackageData.CwccbpJY = {
    Namespace = "Core.RestApi.Server.RestApiEndpointBase",
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

PackageData.dLNnyigy = {
    Namespace = "Core.RestApi.Server.RestApiResponseTemplates",
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
    return RestApiResponse({ Code = StatusCodes.Status200OK }, value)
end

---@param message string
---@return Core.RestApi.RestApiResponse
function RestApiResponseTemplates.BadRequest(message)
    return RestApiResponse({ Code = StatusCodes.Status400BadRequest, Message = message })
end

---@param message string
---@return Core.RestApi.RestApiResponse
function RestApiResponseTemplates.NotFound(message)
    return RestApiResponse({ Code = StatusCodes.Status404NotFound, Message = message })
end

---@param message string
---@return Core.RestApi.RestApiResponse
function RestApiResponseTemplates.InternalServerError(message)
    return RestApiResponse({ Code = StatusCodes.Status500InternalServerError, Message = message })
end

return RestApiResponseTemplates
]]
}

-- ########## Core.RestApi.Server ########## --

PackageData.EaxyWcDY = {
    Namespace = "Core.RestApi.RestApiMethod",
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

PackageData.fphJtVby = {
    Namespace = "Core.RestApi.RestApiRequest",
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

PackageData.GFSURPyY = {
    Namespace = "Core.RestApi.RestApiResponse",
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
    self.WasSuccessfull = self.Headers.Code < 300
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

PackageData.hUCfoIVy = {
    Namespace = "Core.RestApi.StatusCodes",
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

-- ########## Core.RestApi ########## --

PackageData.JjmrMBtY = {
    Namespace = "Core.Json",
    Name = "Json",
    FullName = "Json.lua",
    IsRunnable = true,
    Data = [[
--
-- json.lua
--
-- Copyright (c) 2020 rxi
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do
-- so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

---@class Core.Json
local json = { _version = "0.1.2" }

-------------------------------------------------------------------------------
-- Encode
-------------------------------------------------------------------------------

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

    -- Circular reference?
    if stack[val] then error("circular reference") end

    stack[val] = true

    if rawget(val, 1) ~= nil or next(val) == nil then
        -- Treat as array -- check keys are valid and it is not sparse
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
        -- Encode
        for i, v in ipairs(val) do
            table.insert(res, encode(v, stack))
        end
        stack[val] = nil
        return "[" .. table.concat(res, ",") .. "]"
    else
        -- Treat as an object
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
    -- Check for NaN, -inf and inf
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


---@param val any
---@return string
function json.encode(val)
    return (encode(val))
end

-------------------------------------------------------------------------------
-- Decode
-------------------------------------------------------------------------------

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
    -- http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=iws-appendixa
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
    -- Surrogate pair?
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
        elseif x == 92 then -- `\`: Escape
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
        elseif x == 34 then -- `"`: End of string
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
        -- Empty / end of array?
        if str:sub(i, i) == "]" then
            i = i + 1
            break
        end
        -- Read token
        x, i = parse(str, i)
        res[n] = x
        n = n + 1
        -- Next token
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
        -- Empty / end of object?
        if str:sub(i, i) == "}" then
            i = i + 1
            break
        end
        -- Read key
        if str:sub(i, i) ~= '"' then
            decode_error(str, i, "expected string for key")
        end
        key, i = parse(str, i)
        -- Read ':' delimiter
        i = next_char(str, i, space_chars, true)
        if str:sub(i, i) ~= ":" then
            decode_error(str, i, "expected ':' after key")
        end
        i = next_char(str, i + 1, space_chars, true)
        -- Read value
        val, i = parse(str, i)
        -- Set
        res[key] = val
        -- Next token
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


---@param str string
---@return any
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
]]
}

PackageData.kyXCjvQy = {
    Namespace = "Core.Logger",
    Name = "Logger",
    FullName = "Logger.lua",
    IsRunnable = true,
    Data = [[
local Event = require("Core.Event.Event")

---@alias Core.Logger.LogLevel
---|0 Trace
---|1 Debug
---|2 Info
---|3 Warning
---|4 Error
---|10 Write

---@class Core.Logger : object
---@field OnLog Core.Event
---@field OnClear Core.Event
---@field Name string
---@field private logLevel Core.Logger.LogLevel
---@overload fun(name: string, logLevel: Core.Logger.LogLevel, onLog: Core.Event?, onClear: Core.Event?) : Core.Logger
local Logger = {}

---@param node table
---@param maxLevel number?
---@param properties string[]?
---@param level number?
---@param padding string?
---@return string[]
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
                ---@cast properties string[]
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

function Logger:setErrorLogger()
    _G.__errorLogger = self
end

---@private
---@param name string
---@param logLevel Core.Logger.LogLevel
---@param onLog Core.Event?
---@param onClear Core.Event?
function Logger:__init(name, logLevel, onLog, onClear)
    self.logLevel = logLevel
    self.Name = (string.gsub(name, " ", "_") or "")
    self.OnLog = onLog or Event()
    self.OnClear = onClear or Event()
end

---@param name string
---@return Core.Logger
function Logger:subLogger(name)
    name = self.Name .. "." .. name
    local logger = Logger(name, self.logLevel)
    return self:CopyListenersTo(logger)
end

---@param logger Core.Logger
---@return Core.Logger logger
function Logger:CopyListenersTo(logger)
    self.OnLog:CopyTo(logger.OnLog)
    self.OnClear:CopyTo(logger.OnClear)
    return logger
end

---@param message string
---@param logLevel Core.Logger.LogLevel
function Logger:Log(message, logLevel)
    if logLevel < self.logLevel then
        return
    end

    message = "[" .. self.Name .. "] " .. message
    self.OnLog:Trigger(nil, message)
end

---@param t table
---@param logLevel Core.Logger.LogLevel
---@param maxLevel integer?
---@param properties string[]?
function Logger:LogTable(t, logLevel, maxLevel, properties)
    if logLevel < self.logLevel then
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

---@param logLevel Core.Logger.LogLevel
function Logger:FreeLine(logLevel)
    if logLevel < self.logLevel then
        return
    end

    self.OnLog:Trigger(self, "")
end

---@param message any
function Logger:LogTrace(message)
    if message == nil then return end
    self:Log("TRACE " .. tostring(message), 0)
end

---@param message any
function Logger:LogDebug(message)
    if message == nil then return end
    self:Log("DEBUG " .. tostring(message), 1)
end

---@param message any
function Logger:LogInfo(message)
    if message == nil then return end
    self:Log("INFO " .. tostring(message), 2)
end

---@param message any
function Logger:LogWarning(message)
    if message == nil then return end
    self:Log("WARN " .. tostring(message), 3)
end

---@param message any
function Logger:LogError(message)
    if message == nil then return end
    self:Log("ERROR " .. tostring(message), 4)
end

return Utils.Class.CreateClass(Logger, "Core.Logger")
]]
}

PackageData.LOHNHonY = {
    Namespace = "Core.Path",
    Name = "Path",
    FullName = "Path.lua",
    IsRunnable = true,
    Data = [[
---@class Core.Path
---@field private path string
---@overload fun(path: string?) : Core.Path
local Path = {}

---@param path string
---@boolean
function Path.Static__IsNode(path)
    if path:find("/") then
        return false
    end
    if path:find("\\") then
        return false
    end
    if path:find("|") then
        return false
    end
    return true
end

---@private
---@param path string?
function Path:__init(path)
    if not path or path == "" then
        self.path = ""
        return
    end
    self.path = path:gsub("\\", "/")
end

---@return string
function Path:GetPath()
    return self.path
end

---@param node string
---@return Core.Path
function Path:Append(node)
    local pos = self.path:len() - self.path:reverse():find("/")
    if node == "." or node == ".." or Path.Static__IsNode(node) then
        if pos ~= self.path:len() - 1 then
            self.path = self.path .. "/"
        end
        self.path = self.path .. node
    elseif node == "/" then
        self.path = self.path .. node
    end
    return self
end

---@return string
function Path:GetRoot()
    local str = self:Relative().path
    local slash = str:find("/")
    return str:sub(0, slash)
end

---@return Core.Path
function Path:GetParentFolderPath()
    local pos = self.path:reverse():find("/")
    if not pos then
        return Path()
    end
    local path = self.path:sub(0, self.path:len() - pos)
    return Path(path)
end

---@return boolean
function Path:IsSingle()
    local pos = self.path:find("/", 1)
    return (pos == 0 and self.path:len() > 0 and self.path ~= "/")
end

---@return boolean
function Path:IsAbsolute()
    return self.path:sub(0, 1) == "/"
end

---@return boolean
function Path:IsEmpty()
    return (self.path:len() == 1 and self:IsAbsolute()) or self.path:len() == 0
end

---@return boolean
function Path:IsRoot()
    return self.path == "/"
end

---@return boolean
function Path:IsDir()
    local reversedPath = self.path:reverse()
    return reversedPath:sub(0, 1) == "/"
end

---@param other Core.Path
---@return boolean
function Path:StartsWith(other)
    if other:IsAbsolute() then
        other = other:Absolute()
    else
        other = other:Relative()
    end
    return self.path:sub(0, other.path:len()) == other.path
end

---@return string
function Path:GetFileName()
    local slash = (self.path:reverse():find("/") or 0) - 2
    if slash == nil or slash == -2 then
        return self.path
    end
    return self.path:sub(self.path:len() - slash)
end

---@return string
function Path:GetFileExtension()
    local name = self:GetFileName()
    local pos = (name:reverse():find("%.") or 0) - 1
    if pos == nil or pos == -1 then
        return ""
    end
    return name:sub(name:len() - pos)
end

---@return string
function Path:GetFileStem()
    local name = self:GetFileName()
    local pos = (name:reverse():find("%.") or 0)
    local lenght = name:len()
    if pos == lenght then
        return name
    end
    return name:sub(0, lenght - pos)
end

---@return Core.Path
function Path:Normalize()
    local newPath = Path()
    if self:IsAbsolute() then
        newPath.path = "/"
    end
    local posStart = 0
    local posEnd = self.path:find("/", posStart)
    while true do
        local node = self.path:sub(posStart, posEnd - 1)
        posStart = posEnd + 1
        if node == "." then
        elseif node == ".." then
            local pos = newPath.path:len() - newPath.path:reverse():find("/")
            if pos == nil then
                newPath.path = ""
            else
                newPath.path = newPath.path:sub(pos)
            end
            if newPath.path:len() < 1 and self:IsAbsolute() then
                newPath.path = "/"
            end
        elseif Path.Static__IsNode(node) then
            if newPath.path:len() > 0 and newPath.path:reverse():find("/") ~= 1 then
                newPath.path = newPath.path .. "/"
            end
            newPath.path = newPath.path .. node
        end

        if posEnd == self.path:len() + 1 then
            break
        end

        local newPosEnd = self.path:find("/", posStart)
        if newPosEnd == nil then
            posStart = posEnd + 1
            newPosEnd = self.path:len() + 1
        end
        posEnd = newPosEnd
    end
    return newPath
end

---@return Core.Path
function Path:Absolute()
    if self:IsAbsolute() then
        return Path(self:Normalize().path)
    end
    return Path("/" .. self:Normalize().path)
end

---@return Core.Path
function Path:Relative()
    if self:IsAbsolute() then
        return Path(self:Normalize().path:sub(1))
    end
    return self:Normalize()
end

---@param pathExtension string
---@return Core.Path
function Path:Extend(pathExtension)
    local path = self.path
    local pos = path:len() - path:reverse():find("/")
    if pathExtension == "." or pathExtension == ".." or Path.Static__IsNode(pathExtension) then
        if pos ~= path:len() - 1 then
            path = path .. "/"
        end
        path = path .. pathExtension
    elseif pathExtension == "/" then
        path = path .. pathExtension
    end
    return Path(path)
end

function Path:Copy()
    return Path(self.path)
end

return Utils.Class.CreateClass(Path, "Core.Path")
]]
}

PackageData.mdrYeiKz = {
    Namespace = "Core.Task",
    Name = "Task",
    FullName = "Task.lua",
    IsRunnable = true,
    Data = [[
---@class Core.Task : object
---@field private func function
---@field private parent table
---@field private thread thread
---@field private success boolean
---@field private closed boolean
---@field private results any[]
---@field private noError boolean
---@field private errorObject any
---@overload fun(func: function, parent: table?) : Core.Task
local Task = {}

---@private
---@param ... any parameters
---@return any ... returns
function Task:invokeFunc(...)
    if self.parent then
        return coroutine.yield(self.func(self.parent, ...))
    end
    return coroutine.yield(self.func(...))
end

---@private
---@param func function
---@param parent table
function Task:__init(func, parent)
    self.func = func
    self.parent = parent
    self.closed = false
end

---@return boolean
function Task:IsSuccess()
    return self.success
end

---@return any ... results
function Task:GetResults()
    return table.unpack(self.results)
end

---@return any[] results
function Task:GetResultsArray()
    return self.results
end

---@return any errorObject
function Task:GetErrorObject()
    return self.errorObject
end

---@param success boolean
---@param ... any
---@return boolean success, table returns
local function extractData(success, ...)
    return success, { ... }
end

---@param ... any parameters
---@return any ... results
function Task:Execute(...)
    self.thread = coroutine.create(self.invokeFunc)
    self.success, self.results = extractData(coroutine.resume(self.thread, self, ...))
    return table.unpack(self.results)
end

---@param args any[] parameters
---@return any[] returns
function Task:ExecuteDynamic(args)
    self.thread = coroutine.create(self.invokeFunc)
    self.success, self.results = extractData(coroutine.resume(self.thread, self, table.unpack(args)))
    return self.results
end

---@param ... any parameters
---@return any ... results
function Task:Resume(...)
    if self.thread == nil then
        error("cannot resume not executed task")
    end
    if coroutine.status(self.thread) == "running" or coroutine.status(self.thread) == "dead" then
        error("cannot resume dead or running task")
    end
    self.success, self.results = extractData(coroutine.resume(self.thread, self, ...))
    return table.unpack(self.results)
end

---@param args any[] parameters
---@return any[] returns
function Task:ResumeDynamic(args)
    if self.thread == nil then
        error("cannot resume not executed task")
    end
    if coroutine.status(self.thread) == "running" or coroutine.status(self.thread) == "dead" then
        error("cannot resume dead or running task")
    end
    self.success, self.results = extractData(coroutine.resume(self.thread, self, table.unpack(args)))
    return self.results
end

function Task:Close()
    if self.closed then return end
    self.noError, self.errorObject = coroutine.close(self.thread)
    self.closed = true
end

---@return "not created" | "dead" | "normal" | "running" | "suspended"
function Task:State()
    if self.thread == nil then
        return "not created"
    end
    return coroutine.status(self.thread);
end

---@param logger Core.Logger?
function Task:LogError(logger)
    if not self.noError and logger then
        logger:LogError("execution error: \n" .. debug.traceback(self.thread, self.errorObject) .. debug.traceback():sub(17))
    end
    self:Close()
end

return Utils.Class.CreateClass(Task, "Core.Task")
]]
}

-- ########## Core ########## --

return PackageData
