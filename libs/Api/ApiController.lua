local ApiController = {}
ApiController.__index = ApiController

function ApiController.new(netPort)
    local instance = setmetatable({
        NetPort = netPort,
        _logger = netPort._logger:create("ApiController"),
        Endpoints = {}
    }, ApiController)
    netPort:AddListener("all", {Listener = instance.onMessageRecieved, Object = instance})
    return instance
end

local function excuteCallback(listener, context)
    local status, result
    if listener.Object ~= nil then
        status, result = pcall(listener.Func, listener.Object, context)
    else
        status, result = pcall(listener.Func, context)
    end
    return status, result
end

function ApiController:onMessageRecieved(context)
    for endpointName, listener in pairs(self.Endpoints) do
        if endpointName == context.EventName then
            local status, result = excuteCallback(listener)
            if context.Header.ReturnPort ~= nil then
                self.NetPort.NetClient:SendMessage(context.SenderIPAddress, context.Header.ReturnPort,
                context.EventName, {Success = status, Result = result})
            end
        end
    end
end

function ApiController:AddEndpoint(name, listener)
    if self.Endpoints[name] ~= nil then error("Endpoint allready exsits") end
    self.Endpoints[name] = listener
    return self
end

return ApiController