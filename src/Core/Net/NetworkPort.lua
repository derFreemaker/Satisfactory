local Event = require("Core.Event.Event")

---@class Core.Net.NetworkPort : object
---@field Port integer | "all"
---@field Events Dictionary<string, Core.Event>
---@field Logger Core.Logger
---@overload fun(port: integer | "all", logger: Core.Logger, netClient: Core.Net.NetworkClient) : Core.Net.NetworkPort
local NetworkPort = {}

---@private
---@param port integer | "all"
---@param logger Core.Logger
---@param netClient Core.Net.NetworkClient
function NetworkPort:NetworkPort(port, logger, netClient)
    self.Port = port
    self.Events = {}
    self.Logger = logger
    self.NetClient = netClient
end

---@param context Core.Net.NetworkContext
function NetworkPort:Execute(context)
    self.Logger:LogTrace("got triggered with event: '".. context.EventName .."'")
    for name, event in pairs(self.Events) do
        if name == context.EventName or name == "all" then
            event:Trigger(context)
        end
        if #event == 0 then
            self.Events[name] = nil
        end
    end
end

---@protected
---@param eventName string | "all"
---@return Core.Event
function NetworkPort:GetEvent(eventName)
    for name, event in pairs(self.Events) do
        if name == eventName then
            return event
        end
    end
    local event = Event()
    self.Events[eventName] = event
    return event
end

---@param onRecivedEventName string | "all"
---@param listener Core.Listener
---@return Core.Net.NetworkPort
function NetworkPort:AddListener(onRecivedEventName, listener)
    local event = self:GetEvent(onRecivedEventName)
    event:AddListener(listener)
    return self
end
NetworkPort.On = NetworkPort.AddListener

---@param onRecivedEventName string | "all"
---@param listener Core.Listener
---@return Core.Net.NetworkPort
function NetworkPort:AddListenerOnce(onRecivedEventName, listener)
    local event = self:GetEvent(onRecivedEventName)
    event:AddListenerOnce(listener)
    return self
end
NetworkPort.Once = NetworkPort.AddListenerOnce

function NetworkPort:OpenPort()
    local port = self.Port
    if type(port) == "number" then
        self.NetClient:OpenPort(port)
    end
end

function NetworkPort:ClosePort()
    local port = self.Port
    if type(port) == "number" then
        self.NetClient:ClosePort(port)
    end
end

return Utils.Class.CreateClass(NetworkPort, "NetworkPort")