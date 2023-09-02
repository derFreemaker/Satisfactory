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
function RestApiController:RestApiController(netPort, logger)
    self.Endpoints = {}
    self.netPort = netPort
    self.logger = logger
    netPort:AddListener("Rest-Request", Task(self.onMessageRecieved, self))
end

---@param context Core.Net.NetworkContext
function RestApiController:onMessageRecieved(context)
    local request = RestApiRequest.Static__CreateFromNetworkContext(context)
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
    return nil
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