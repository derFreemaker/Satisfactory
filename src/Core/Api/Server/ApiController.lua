-- //TODO: more log messages for debuging

local Listener = require("Core.Event.Listener")
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
    netPort:AddListener("Rest-Request", Listener(self.onMessageRecieved, self))
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
---@param listener Core.Task
---@return Core.Api.Server.ApiController
function ApiController:AddEndpoint(name, listener)
    if self:GetEndpoint(name) ~= nil then
        error("Endpoint allready exists")
    end
    self.Endpoints[name] = ApiEndpoint(listener)
    return self
end

return Utils.Class.CreateClass(ApiController, "ApiController")