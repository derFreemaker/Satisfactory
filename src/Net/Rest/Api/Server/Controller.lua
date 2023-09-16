local Task = require("Core.Task")
local RestApiEndpoint = require("Net.Rest.Api.Server.Endpoint")
local RestApiResponseTemplates = require("Net.Rest.Api.Server.ResponseTemplates")
local RestApiMethod = require("Net.Rest.Api.Method")

---@class Net.Rest.Api.Server.Controller : object
---@field Endpoints Dictionary<string, Net.Rest.Api.Server.Endpoint>
---@field private netPort Core.Net.NetworkPort
---@field private logger Core.Logger
---@overload fun(netPort: Core.Net.NetworkPort, logger: Core.Logger) : Net.Rest.Api.Server.Controller
local Controller = {}

---@private
---@param netPort Core.Net.NetworkPort
---@param logger Core.Logger
function Controller:__init(netPort, logger)
    self.Endpoints = {}
    self.netPort = netPort
    self.logger = logger
    netPort:AddListener("Rest-Request", Task(self.onMessageRecieved, self))
end

---@private
---@param context Core.Net.NetworkContext
function Controller:onMessageRecieved(context)
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
    self.logger:LogTrace("found endpoint: " .. request.Endpoint)
    endpoint:Execute(request, context, self.netPort:GetNetClient())
end

---@param method Net.Rest.Api.Method
---@param endpointName string
---@return Net.Rest.Api.Server.Endpoint?
function Controller:GetEndpoint(method, endpointName)
    for name, endpoint in pairs(self.Endpoints) do
        if name == method .. "__" .. endpointName then
            return endpoint
        end
    end
end

---@param method Net.Rest.Api.Method
---@param name string
---@param task Core.Task
---@return Net.Rest.Api.Server.Controller
function Controller:AddEndpoint(method, name, task)
    if self:GetEndpoint(method, name) ~= nil then
        error("Endpoint allready exists")
    end
    local endpointName = method .. "__" .. name
    self.Endpoints[endpointName] = RestApiEndpoint(task, self.logger:subLogger("RestApiEndpoint[" .. endpointName .. "]"))
    self.logger:LogTrace("Added endpoint: '" .. method .. "' -> '" .. name .. "'")
    return self
end

---@param endpoint Net.Rest.Api.Server.EndpointBase
function Controller:AddRestApiEndpointBase(endpoint)
    for name, func in pairs(endpoint) do
        if type(name) == "string" and type(func) == "function" then
            local method, endpointName = name:match("^(.+)__(.+)$")
            if method ~= nil and endpoint ~= nil and RestApiMethod[method] then
                self:AddEndpoint(method, endpointName, Task(func, endpoint))
            end
        end
    end
end

return Utils.Class.CreateClass(Controller, "Net.Rest.Api.Server.Controller")
