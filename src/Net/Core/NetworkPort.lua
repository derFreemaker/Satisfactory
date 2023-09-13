local Event = require("Core.Event.Event")

---@class Core.Net.NetworkPort : object
---@field Port integer | "all"
---@field private events Dictionary<string, Core.Event>
---@field private netClient Core.Net.NetworkClient
---@field private logger Core.Logger
---@overload fun(port: integer | "all", logger: Core.Logger, netClient: Core.Net.NetworkClient) : Core.Net.NetworkPort
local NetworkPort = {}

---@private
---@param port integer | "all"
---@param logger Core.Logger
---@param netClient Core.Net.NetworkClient
function NetworkPort:__init(port, logger, netClient)
    self.Port = port
    self.events = {}
    self.logger = logger
    self.netClient = netClient
end

---@return Dictionary<string, Core.Event>
function NetworkPort:GetEvents()
    return Utils.Table.Copy(self.events)
end

---@return Core.Net.NetworkClient
function NetworkPort:GetNetClient()
    return self.netClient
end

---@param context Core.Net.NetworkContext
function NetworkPort:Execute(context)
    self.logger:LogTrace("got triggered with event: '".. context.EventName .."'")
    for name, event in pairs(self.events) do
        if name == context.EventName or name == "all" then
            event:Trigger(self.logger, context)
        end
        if #event == 0 then
            self.events[name] = nil
        end
    end
end

---@protected
---@param eventName string | "all"
---@return Core.Event
function NetworkPort:GetEvent(eventName)
    for name, event in pairs(self.events) do
        if name == eventName then
            return event
        end
    end
    local event = Event()
    self.events[eventName] = event
    return event
end

---@param onRecivedEventName string | "all"
---@param listener Core.Task
---@return Core.Net.NetworkPort
function NetworkPort:AddListener(onRecivedEventName, listener)
    local event = self:GetEvent(onRecivedEventName)
    event:AddListener(listener)
    return self
end
NetworkPort.On = NetworkPort.AddListener

---@param onRecivedEventName string | "all"
---@param listener Core.Task
---@return Core.Net.NetworkPort
function NetworkPort:AddListenerOnce(onRecivedEventName, listener)
    local event = self:GetEvent(onRecivedEventName)
    event:AddListenerOnce(listener)
    return self
end
NetworkPort.Once = NetworkPort.AddListenerOnce

---@param eventName string
---@param timeout number?
---@return Core.Net.NetworkContext?
function NetworkPort:WaitForEvent(eventName, timeout)
    return self.netClient:WaitForEvent(eventName, self.Port, timeout)
end

function NetworkPort:OpenPort()
    local port = self.Port
    if type(port) == "number" then
        self.netClient:OpenPort(port)
    end
end

function NetworkPort:ClosePort()
    local port = self.Port
    if type(port) == "number" then
        self.netClient:ClosePort(port)
    end
end

---@param ipAddress string
---@param eventName string
---@param body any
---@param header Dictionary<string, any>?
function NetworkPort:SendMessage(ipAddress, eventName, body, header)
    local port = self.Port
    if port == "all" then
        error("Unable to send a message over all ports")
    end
    ---@cast port integer
    self.netClient:SendMessage(ipAddress, port, eventName, body, header)
end

---@param eventName string
---@param body any
---@param header Dictionary<string, any>?
function NetworkPort:BroadCastMessage(eventName, body, header)
    local port = self.Port
    if port == "all" then
        error("Unable to broadcast a message over all ports")
    end
    ---@cast port integer
    self.netClient:BroadCastMessage(port, eventName, body, header)
end

return Utils.Class.CreateClass(NetworkPort, "Core.Net.NetworkPort")