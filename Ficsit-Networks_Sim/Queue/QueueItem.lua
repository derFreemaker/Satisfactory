---@class Ficsit_Networks_Sim.Queue.QueueItem
---@field Id string
---@field Data any
---@field Queue Ficsit_Networks_Sim.Queue.Queue
local QueueItem = {}
QueueItem.__index = QueueItem

---@param itemId string
---@param data any
---@param queue Ficsit_Networks_Sim.Queue.Queue
---@return Ficsit_Networks_Sim.Queue.QueueItem
function QueueItem.new(itemId, data, queue)
    return setmetatable({
        Id = itemId,
        Data = data,
        Queue = queue
    }, QueueItem)
end

function QueueItem:Delete()
    self.Queue:RemoveFromQueue(self.Id)
end

return QueueItem