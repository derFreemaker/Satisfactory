local Task = require("Core.Task")
local RestApiEndpoint = require("Core.RestApi.Server.RestApiEndpoint")
local RestApiHelper = require("Core.RestApi.RestApiHelper")
local RestApiResponseTemplates = require("Core.RestApi.Server.RestApiResponseTemplates")
local RestApiMethod = require("Core.RestApi.RestApiMethod")

---@class Core.RestApi.Server.RestApiController : object
---@field Endpoints Dictionary<string, Core.RestApi.Server.RestApiEndpoint>
---@field NetPort Core.Net.NetworkPort
---@field Logger Core.Logger
---@overload fun(netPort: Core.Net.NetworkPort) : Core.RestApi.Server.RestApiController
local RestApiController = {}

---@private
---@param netPort Core.Net.NetworkPort
function RestApiController:RestApiController(netPort)
    self.Endpoints = {}
    self.NetPort = netPort
    self.Logger = netPort.Logger:subLogger("RestApiController")
    netPort:AddListener("Rest-Request", Task(self.onMessageRecieved, self))
end

---@param context Core.Net.NetworkContext
function RestApiController:onMessageRecieved(context)
    local request = RestApiHelper.NetworkContextToRestApiRequest(context)
    self.Logger:LogDebug("recieved request on endpoint: '" .. request.Endpoint .. "'")
    local endpoint = self:GetEndpoint(request.Method, request.Endpoint)
    if endpoint == nil then
        self.Logger:LogTrace("found no endpoint")
        if context.Header.ReturnPort then
            self.NetPort.NetClient:SendMessage(context.SenderIPAddress, context.Header.ReturnPort,
                "Rest-Response", nil, RestApiResponseTemplates.NotFound("Unable to find endpoint"))
        end
        return
    end
    endpoint:Execute(request, context, self.NetPort.NetClient)
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
    self.Endpoints[name] = RestApiEndpoint(task, self.Logger:subLogger("RestApiEndpoint[".. name .."]"))
    return self
end

---@param endpointBase Core.RestApi.Server.RestApiEndpointBase
function RestApiController:AddRestApiEndpointBase(endpointBase)
    for name, func in pairs(endpointBase) do
        if type(name) == "string" and type(func) == "function" then
            local method, endpointName = name:match("^(.+)__(.+)$")
            if method ~= nil and endpointBase ~= nil and RestApiMethod[method] == method then
                self:AddEndpoint(method, endpointName, Task(func, endpointBase))
            end
        end
    end
end

return Utils.Class.CreateClass(RestApiController, "RestApiController")