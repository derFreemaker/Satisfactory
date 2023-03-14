local Event = ModuleLoader.GetModule("Event")

local NetworkPort = {}
NetworkPort.__index = NetworkPort

function NetworkPort.new(port, logger, netClient)
    local instance = setmetatable({
        Port = port,
        Events = {},
        logger = logger:create("Port:'"..port.."'"),
        NetClient = netClient
    }, NetworkPort)
    return instance
end

function NetworkPort:executeCallback(context)
    local removeEvent = {}
    for i, event in pairs(self.Events) do
        if event.EventName == context.EventName or event.EventName == "all" then
            event.Event:Trigger(context)
        end
        if #event:Listeners() == 0 then
            table.insert(removeEvent, {Pos = i, Event = event})
        end
    end
    for _, event in pairs(removeEvent) do
        event.Event:ClosePort()
        table.remove(self.Events, event.Pos)
    end
end

function NetworkPort:AddListener(onRecivedEventName, listener)
    for _, event in pairs(self.Events) do
        if event.EventName == onRecivedEventName then
            event.Event:AddListener(listener.Func, listener.Object)
            return
        end
    end

    local event = Event.new(onRecivedEventName, self.logger)
    event:AddListener(listener.Func, listener.Object)
    self.Events = {EventName = onRecivedEventName, Event = event}
    return self
end

function NetworkPort:AddListenerOnce(onRecivedEventName, listener)
    for _, event in pairs(self.Events) do
        if event.EventName == onRecivedEventName then
            event.Event:AddListenerOnce(listener.Func, listener.Object)
            return
        end
    end

    local event = Event.new(onRecivedEventName, self.logger)
    event:AddListenerOnce(listener.Func, listener.Object)
    self.Events = {EventName = onRecivedEventName, Event = event}
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