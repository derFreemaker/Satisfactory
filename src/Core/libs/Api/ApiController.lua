local Listener = require("libs.Listener")
local ApiEndpoint = require("libs.Api.ApiEndpoint")

---@class ApiController
---@field Endpoints ApiEndpoint[]
---@field NetPort NetworkPort
---@field Logger Logger
local ApiController = {}
ApiController.__index = ApiController

---@param netPort NetworkPort
---@return ApiController
function ApiController.new(netPort)
    local instance = setmetatable({
        NetPort = netPort,
        _logger = netPort.Logger:create("ApiController"),
        Endpoints = {}
    }, ApiController)
    netPort:AddListener("all", Listener.new(instance.onMessageRecieved, instance))
    return instance
end

---@param context NetworkContext
function ApiController:onMessageRecieved(context)
    self.Logger:LogTrace("recieved request on endpoint: " .. context.EventName)
    local thread, success, result = self:ExcuteEndpoint(context)
    if context.Header.ReturnPort ~= nil then
        self.NetPort.NetClient:SendMessage(context.SenderIPAddress, context.Header.ReturnPort,
            context.EventName, { Success = success, Result = result })
    end
    if success then
        self.Logger:LogTrace("request finished successfully")
    else
        self.Logger:LogTrace("request finished with error: " .. debug.traceback(thread, result))
    end
end

---@param name string
---@return ApiEndpoint | nil
function ApiController:GetEndpoint(name)
    for _, endpoint in pairs(self.Endpoints) do
        if endpoint.Name == name then
            return endpoint
        end
    end
    return nil
end

---@param name string
---@param listener Listener
---@return ApiController
function ApiController:AddEndpoint(name, listener)
    if self:GetEndpoint(name) ~= nil then error("Endpoint allready exsits") end
    table.insert(self.Endpoints, ApiEndpoint.new(name, listener))
    return self
end

---@param context NetworkContext
---@return thread | nil, boolean, 'result' | 'error'
function ApiController:ExcuteEndpoint(context)
    local endpoint = self.Endpoints[""]
    if endpoint == nil then
        local NotFound = "Not Found"
        ---@cast NotFound 'result'
        return nil, false, NotFound
    end
    return endpoint:Execute(self.Logger, context)
end

return ApiController
