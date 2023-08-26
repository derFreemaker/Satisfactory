-- //TODO: more log messages for debuging

local Task = require("Core.Task")
local ApiEndpoint = require("Core.Api.Server.ApiEndpoint")
local ApiHelper = require("Core.Api.ApiHelper")
local StatusCodes = require("Core.Api.StatusCodes")
local ApiResponseTemplates = require("Core.Api.Server.ApiResponseTemplates")

---@class Core.Api.Server.ApiController : object
---@field Endpoints Dictionary<string, Core.Api.Server.ApiEndpoint>
---@field NetPort Core.Net.NetworkPort
---@field Logger Core.Logger
---@overload fun(netPort: Core.Net.NetworkPort) : Core.Api.Server.ApiController
local ApiController = {}

---@private
---@param netPort Core.Net.NetworkPort
function ApiController:ApiController(netPort)
    self.Endpoints = {}
    self.NetPort = netPort
    self.Logger = netPort.Logger:subLogger("ApiController")
    netPort:AddListener("Rest-Request", Task(self.onMessageRecieved, self))
end

---@param context Core.Net.NetworkContext
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
    endpoint:Execute(request, context, self.NetPort.NetClient)
end

---@param endpointName string
---@return Core.Api.Server.ApiEndpoint?
function ApiController:GetEndpoint(endpointName)
    for name, endpoint in pairs(self.Endpoints) do
        if name == endpointName then
            return endpoint
        end
    end
    return nil
end

---@param name string
---@param task Core.Task
---@return Core.Api.Server.ApiController
function ApiController:AddEndpoint(name, task)
    if self:GetEndpoint(name) ~= nil then
        error("Endpoint allready exists")
    end
    self.Endpoints[name] = ApiEndpoint(task, self.Logger:subLogger("ApiEndpoint[".. name .."]"))
    return self
end

return Utils.Class.CreateClass(ApiController, "ApiController")