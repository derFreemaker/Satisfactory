local Tools = require("Ficsit-Networks_Sim.Utils.Tools")
local JsonConverter = require("Ficsit-Networks_Sim.Utils.JsonConverter")
local Event = require("Ficsit-Networks_Sim.Utils.Event")
local QueueItem = require("Ficsit-Networks_Sim.Queue.QueueItem")

---@class Ficsit_Networks_Sim.Queue.Queue
---@field queueFolder Ficsit_Networks_Sim.Filesystem.Path
---@field CurrentQueueId string
---@field Callback Ficsit_Networks_Sim.Utils.Event
local Queue = {}
Queue.__index = Queue

---@param queueFolder Ficsit_Networks_Sim.Filesystem.Path
---@param currentQueueId string
---@return Ficsit_Networks_Sim.Queue.Queue
function Queue.new(queueFolder, currentQueueId)
    return setmetatable({
        queueFolder = queueFolder,
        CurrentQueueId = currentQueueId,
        Callback = Event.new()
    }, Queue)
end

---@return Array<string>
function Queue:GetQueueFiles()
    local result = io.popen("dir \"" .. self.queueFolder:GetPath() .. "\" /b /o")
    if result == nil then
        return {}
    end
    ---@type string[]
    local childs = {}
    for line in result:lines() do
        if line:find("%.queue%.json") then
            table.insert(childs, line)
        end
    end
    return childs
end

---@private
---@return string
function Queue:GetNextQueueFileName()
    ---@type string
    local path
    repeat
        path = self.queueFolder:Extend(Tools.RandomString(5) .. ".queue.json"):GetPath()
    until not os.rename(path, path)
    return path
end

---@param body table
---@param headers Dictionary<string> | nil
function Queue:AddToQueue(body, headers)
    local path = self:GetNextQueueFileName()
    local file = io.open(path, "w")
    if not file then
        error("Unable to open file: '" .. path .. "'")
    end
    file:write(JsonConverter.encode({
        Headers = (headers or {}),
        Body = body,
    }))
    file:close()
end

---@param id string
function Queue:RemoveFromQueue(id)
    local path = self.queueFolder:Extend(id .. ".queue.json"):GetPath()
    os.remove(path)
end

---@param filePath string
function Queue:CheckQueueItem(filePath)
    local file = io.open(self.queueFolder:Extend(filePath):GetPath())
    if not file then
        error("Unable to open file: '" .. filePath .. "'")
    end
    local data = JsonConverter.decode(file:read("a"))
    file:close()
    local pointPos = filePath:find("%.") - 1
    local id = filePath:sub(0, pointPos)
    local queueItem = QueueItem.new(id, data, self)
    self.Callback:Trigger(queueItem)
end

function Queue:CheckQueueFolder()
    for _, queueFile in ipairs(self:GetQueueFiles()) do
        self:CheckQueueItem(queueFile)
    end
end

return Queue
