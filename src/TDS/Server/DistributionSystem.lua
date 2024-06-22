local UUID = require("Core.Common.UUID")

local TrainStacker = require("TDS.Server.TrainStacker")
local Train = require("TDS.Server.Entities.Train")

local NEW_TRAIN_NAME = "__NEW_TRAIN__"
local TRAINS_FULL_NAME = "__TRAINS_FULL__"

---@class TDS.Server.DistributionSystem : object
---@field m_queue TDS.Entities.Request[]
---@field m_maxTrains integer
---@field m_trains Database.DbTable<string, TDS.Server.Entities.Train>
---@field m_stations Database.DbTable<string, TDS.Server.Entities.Station>
---@field m_requests Database.DbTable<string, TDS.Entities.Request>
---@field m_trainStacker TDS.Server.TrainStacker
---@field m_logger Core.Logger
---@overload fun(logger: Core.Logger) : TDS.Server.DistributionSystem
local DistributionSystem = {}

---@private
---@param logger Core.Logger
function DistributionSystem:__init(logger)
    self.m_trainStacker = TrainStacker(Config.StationId)
    self.m_logger = logger

    self.m_logger:LogInfo("you can add trains by naming them: " .. NEW_TRAIN_NAME)
end

function DistributionSystem:Save()
    self.m_trains:Save()
end

---@private
---@param train Satis.Train
function DistributionSystem:AddTrain(train)
    local uuid = UUID.Static__New()
    train:setName(uuid:ToString())

    local trainObj = Train(uuid, "Traveling")
    self.m_trainStacker:CallbackTrain(trainObj:GetRef())

    self.m_trains:Add(uuid:ToString(), trainObj)
end

function DistributionSystem:Check()
    local connectedStation = self.m_trainStacker:GetStationReference()
    local trackGraph = connectedStation:Get():getTrackGraph()

    local trains = trackGraph:getTrains()
    for _, train in pairs(trains) do
        if train:getName() == NEW_TRAIN_NAME then
            if self.m_trains:Count() > self.m_maxTrains then
                train:setName(TRAINS_FULL_NAME)
                goto continue
            end

            self:AddTrain(train)
        end

        ::continue::
    end
end

function DistributionSystem:Distribute()
    --//TODO: implement DistributionSystem:Distribute()
    --//TODO: check if station and train still exists when used
    --//TODO: check if train is useable and not derailed or ... ([train].isDerailed)

    for key, value in pairs(self.m_requests:Iterator()) do
        ---@cast key string
        ---@cast value TDS.Entities.Request

        
    end
end

---@param itemName string
---@return TDS.Server.Entities.Station | nil
function DistributionSystem:GetLoadStation(itemName)
    for uuid, station in pairs(self.m_stations:Iterator()) do
        ---@cast uuid string
        ---@cast station TDS.Server.Entities.Station

        if not station:IsValid() then
            self.m_stations:Remove(uuid)
            goto continue
        end

        if station.ItemName == itemName then
            return station
        end

        ::continue::
    end
end

function DistributionSystem:Cycle()
    self:Check()

    self:Distribute()

    self.m_trains:Save()
    self.m_stations:Save()
    self.m_requests:Save()
end

return class("TDS.Server.DistributionSystem", DistributionSystem)
