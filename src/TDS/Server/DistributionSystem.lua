local UUID = require("Core.Common.UUID")

local TrainStacker = require("TDS.Server.TrainStacker")


local NEW_TRAIN_NAME = "__NEW_TRAIN__"
local TRAINS_FULL_NAME = "__TRAINS_FULL__"

---@class TDS.Server.DistributionSystem : object
---@field m_queue TDS.Entities.Request[]
---@field m_maxTrains integer
---@field m_trainStacker TDS.Server.TrainStacker
---@field m_databaseAccessLayer TDS.Server.DatabaseAccessLayer
---@field m_logger Core.Logger
---@overload fun(logger: Core.Logger, databaseAccessLayer: TDS.Server.DatabaseAccessLayer) : TDS.Server.DistributionSystem
local DistributionSystem = {}

---@private
---@param logger Core.Logger
---@param databaseAccessLayer TDS.Server.DatabaseAccessLayer
function DistributionSystem:__init(logger, databaseAccessLayer)
    self.m_trainStacker = TrainStacker(Config.StationId)
    self.m_databaseAccessLayer = databaseAccessLayer
    self.m_logger = logger

    self.m_logger:LogInfo("you can add trains by naming them: " .. NEW_TRAIN_NAME)
end

---@private
---@param train Satis.Train
function DistributionSystem:AddTrain(train)
    local trainObj = self.m_databaseAccessLayer:CreateTrain({ State = "Traveling" })
    train:setName(trainObj.Id:ToString())

    self.m_trainStacker:CallbackTrain(trainObj:GetRef())
end

function DistributionSystem:Check()
    local connectedStation = self.m_trainStacker:GetStationReference()
    local trackGraph = connectedStation:Get():getTrackGraph()

    local trains = trackGraph:getTrains()
    for _, train in pairs(trains) do
        if train:getName() == NEW_TRAIN_NAME then
            if self.m_databaseAccessLayer:TrainsCount() > self.m_maxTrains then
                train:setName(TRAINS_FULL_NAME)
                goto continue
            end

            self:AddTrain(train)
        end

        ::continue::
    end
end

function DistributionSystem:Distribute()
    for key, value in pairs(self.m_databaseAccessLayer:RequestsIterator()) do
        ---@cast key string
        ---@cast value TDS.Entities.Request

        --//TODO: process requests
        --//TODO: check stations and train still valid
    end
end

---@param itemName string
---@return TDS.Server.Entities.Station | nil
function DistributionSystem:GetLoadStation(itemName)
    for _, station in pairs(self.m_databaseAccessLayer:StationsIterator()) do
        ---@cast station TDS.Server.Entities.Station

        if not station:IsValid() then
            self.m_databaseAccessLayer:RemoveStation(station.Id)
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
end

return class("TDS.Server.DistributionSystem", DistributionSystem)
