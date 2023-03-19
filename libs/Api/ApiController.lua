local Listener = require("libs.Listener")

local ApiController = {}
ApiController.__index = ApiController

function ApiController.new(netPort)
    local instance = setmetatable({
        NetPort = netPort,
        _logger = netPort._logger:create("ApiController"),
        Endpoints = {}
    }, ApiController)
    netPort:AddListener("all", { Func = instance.onMessageRecieved, Object = instance })
    return instance
end

function ApiController:excuteEndpoint(context)
    local endpoint = self.Endpoints[context.EventName]
    if endpoint == nil then
        return nil, false, "Not found"
    end
    return endpoint:Execute(self._logger, context)
end

function ApiController:onMessageRecieved(context)
    self._logger:LogTrace("recieved request on endpoint: " .. context.EventName)
    local thread, success, result = self:excuteEndpoint(context)
    if context.Header.ReturnPort ~= nil then
        self.NetPort.NetClient:SendMessage(context.SenderIPAddress, context.Header.ReturnPort,
            context.EventName, { Success = success, Result = result })
    end
    if success then
        self._logger:LogTrace("request finished successfully")
    else
        self._logger:LogTrace("request finished with error: " .. debug.traceback(thread, result))
    end
end

function ApiController:AddEndpoint(name, listener)
    if self.Endpoints[name] ~= nil then error("Endpoint allready exsits") end
    self.Endpoints[name] = listener
    return self
end

return ApiController
