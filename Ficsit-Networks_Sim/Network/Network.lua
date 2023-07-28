local Queue = require("Ficsit-Networks_Sim.Queue.Queue")
local Event = require("Ficsit-Networks_Sim.Utils.Event")
local Listener = require("Ficsit-Networks_Sim.Utils.Listener")

---@class Ficsit_Networks_Sim.Network.Network
---@field OnMessageRecieved Ficsit_Networks_Sim.Utils.Event
---@field private Queue Ficsit_Networks_Sim.Queue.Queue
---@field private logger Ficsit_Networks_Sim.Utils.Logger
local Network = {}
Network.__index = Network

---@param queueFolderPath Ficsit_Networks_Sim.Filesystem.Path
---@param networkId string
---@param logger Ficsit_Networks_Sim.Utils.Logger
---@return Ficsit_Networks_Sim.Network.Network
function Network.new(queueFolderPath, networkId, logger)
    local instance = setmetatable({
        Queue = Queue.new(queueFolderPath, networkId),
        OnMessageRecieved = Event.new(),
        logger = logger
    }, Network)
    instance.Queue.Callback:On(Listener.new(instance.OnMessageRecieved.Trigger))
    return instance
end

---@param ... any
---@return table
local function checkData(...)
    local data = table.pack(...)
    if #data > 7 then
        error("You can not use more than 7 for data parameters.", 2)
    end
    for index, value in ipairs(data) do
        local valueType = type(value)
        if valueType ~= "nil"
            and valueType ~= "boolean"
            and valueType ~= "number"
            and valueType ~= "string" then
            error("You are not able use type: '".. valueType .."' at index: '".. index .."'. Only 'nil', 'boolean', 'number' and 'string'", 3)
        end
    end
    return data
end

---@param signalName string
---@param componentSenderId string
---@param componentRecieverId string
---@param ... any
function Network:SendMessage(signalName, componentSenderId, componentRecieverId, ...)
    local headers = {
        SignalName = signalName,
        ComponentSenderId = componentSenderId,
        ComponentRecieverId = componentRecieverId
    }
    self.Queue:AddToQueue(checkData(...), headers)
end

function Network:RecieveMessages()
    self.Queue:CheckQueueFolder()
end

return Network