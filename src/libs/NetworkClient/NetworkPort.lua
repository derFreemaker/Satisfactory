local Event = require("libs.Event")

---@class NetworkPort
---@field Logger Logger
---@field Events Event[]
---@field Port number
---@field NetClient NetworkClient
local NetworkPort = {}
NetworkPort.__index = NetworkPort

---@param port number
---@param logger Logger
---@param netClient NetworkClient
---@return NetworkPort
function NetworkPort.new(port, logger, netClient)
    local instance = setmetatable({
        Port = port,
        Events = {},
        Logger = logger:create("Port:'"..port.."'"),
        NetClient = netClient
    }, NetworkPort)
    return instance
end

---@param context NetworkContext
function NetworkPort:executeCallback(context)
    self.Logger:LogTrace("got triggerd with event: "..context.EventName)
    local removeEvent = {}
    for i, event in pairs(self.Events) do
        if event.Name == context.EventName or event.Name == "all" then
            event:Trigger(context)
        end
        if #event:Listeners() == 0 then
            table.insert(removeEvent, {Pos = i, Event = event})
        end
    end
    for _, event in pairs(removeEvent) do
        table.remove(self.Events, event.Pos)
    end
end

---@param onRecivedEventName string
---@param listener Listener
---@return NetworkPort
function NetworkPort:AddListener(onRecivedEventName, listener)
    for _, event in pairs(self.Events) do
        if event.Name == onRecivedEventName then
            event:AddListener(listener)
            return self
        end
    end

    local event = Event.new(onRecivedEventName, self.Logger)
    event:AddListener(listener)
    table.insert(self.Events, event)
    return self
end

---@param onRecivedEventName string
---@param listener Listener
---@return NetworkPort
function NetworkPort:AddListenerOnce(onRecivedEventName, listener)
    for _, event in pairs(self.Events) do
        if event.Name == onRecivedEventName then
            event:AddListenerOnce(listener)
            return self
        end
    end

    local event = Event.new(onRecivedEventName, self.Logger)
    event:AddListenerOnce(listener)
    table.insert(self.Events, event)
    return self
end

function NetworkPort:OpenPort()
    if type(self.Port) == "number" then
        self.NetClient:OpenPort(self.Port)
    end
end

function NetworkPort:ClosePort()
    if type(self.Port) == "number" then
        self.NetClient:ClosePort(self.Port)
    end
end

return NetworkPort