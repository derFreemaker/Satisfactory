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
    for endpointName, listener in pairs(self.Endpoints) do
        if endpointName == context.EventName then
            local thread = coroutine.create(listener.Func)
            local status, result
            if listener.Object ~= nil then
                status, result = coroutine.resume(thread, listener.Object, context)
            else
                status, result = coroutine.resume(thread, context)
            end
            return status, result, thread
        end
    end
end

function ApiController:onMessageRecieved(context)
    self._logger:LogTrace("recieved request on endpoint: " .. context.EventName)
    local status, result, thread = self:excuteEndpoint(context)
    if context.Header.ReturnPort ~= nil then
        self.NetPort.NetClient:SendMessage(context.SenderIPAddress, context.Header.ReturnPort,
            context.EventName, { Success = status, Result = result })
    end
    if status then self._logger:LogTrace("request finished successfully")
    else self._logger:LogTrace("request finished with error: " .. debug.traceback(thread, result))
    end
end

function ApiController:AddEndpoint(name, listener)
    if self.Endpoints[name] ~= nil then error("Endpoint allready exsits") end
    self.Endpoints[name] = listener
    return self
end

return ApiController
