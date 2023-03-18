local Event = require("Event")

local NetworkPort = {}
NetworkPort.__index = NetworkPort

function NetworkPort.new(port, logger, netClient)
    local instance = setmetatable({
        Port = port,
        Events = {},
        _logger = logger:create("Port:'"..port.."'"),
        NetClient = netClient
    }, NetworkPort)
    return instance
end

function NetworkPort:executeCallback(context)
    self._logger:LogTrace("got triggerd with event: "..context.EventName)
    local removeEvent = {}
    for i, event in pairs(self.Events) do
        if event.EventName == context.EventName or event.EventName == "all" then
            event.Event:Trigger(context)
        end
        if #event.Event:Listeners() == 0 then
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
            event.Event:AddListener(listener)
            return
        end
    end

    local event = Event.new(onRecivedEventName, self._logger)
    event:AddListener(listener)
    table.insert(self.Events, {EventName = onRecivedEventName, Event = event})
end

function NetworkPort:AddListenerOnce(onRecivedEventName, listener)
    for _, event in pairs(self.Events) do
        if event.EventName == onRecivedEventName then
            event.Event:AddListenerOnce(listener)
            return
        end
    end

    local event = Event.new(onRecivedEventName, self._logger)
    event:AddListenerOnce(listener)
    table.insert(self.Events, {EventName = onRecivedEventName, Event = event})
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