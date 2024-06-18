local UUID = require("Core.Common.UUID")

local Train = require("TDS.Server.Entities.Train")

NEW_NAME = "__NEW_TRAIN__"

---@class TDS.Server.DistributionSystem : object
---@field m_queue TDS.Entities.Request[]
---@field m_trains Database.DbTable<string, TDS.Server.Entities.Train>
---@field m_stations Database.DbTable<string, TDS.Server.Entities.Station>
---@field m_requests Database.DbTable<string, TDS.Entities.Request>
---@field m_logger Core.Logger
---@overload fun(logger: Core.Logger) : TDS.Server.DistributionSystem
local DistributionSystem = {}

---@private
---@param logger Core.Logger
function DistributionSystem:__init(logger)
    self.m_logger = logger

    self.m_logger:LogInfo("you can add trains by naming them: " .. NEW_NAME)
end

function DistributionSystem:Save()
    self.m_trains:Save()
end

---@private
---@param train TDS.Server.Entities.Train
function DistributionSystem:SendToBase(train)
    local trainRef = train:GetRef()

    --//TODO: send train to base
    --//TODO: figure out how to stack trains
end

---@private
---@param train Satis.Train
function DistributionSystem:AddTrain(train)
    local uuid = UUID.Static__New()
    train:setName(uuid:ToString())

    local trainObj = Train(uuid, "Traveling")
    self:SendToBase(trainObj)

    self.m_trains:Set(uuid:ToString(), trainObj)
end

function DistributionSystem:Check()
    ---@type Satis.TrainPlatform
    local connectedStation = component.proxy(Config.StationId)
    if not connectedStation then
        error("Config.StationId is invalid or was not found")
    end
    local trackGraph = connectedStation:getTrackGraph()

    local trains = trackGraph:getTrains()
    for _, train in pairs(trains) do
        local timeTable = train:newTimeTable()

        if train:getName() == NEW_NAME then
            self:AddTrain(train)
        end
    end
end

function DistributionSystem:Distribute()
    --//TODO: implement DistributionSystem:Distribute()
    --//TODO: check if station and train still exists when used
    --//TODO: check if train is useable and not unrailed or ...
end

function DistributionSystem:Run()
    self:Check()

    self:Distribute()
end

return class("TDS.Server.DistributionSystem", DistributionSystem)
