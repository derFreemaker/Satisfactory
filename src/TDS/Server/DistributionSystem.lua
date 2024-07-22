local UUID = require("Core.Common.UUID")
local ProxyReference = require("Core.Reference.ProxyReference")

local TrainStacker = require("TDS.Server.TrainStacker")


local NEW_TRAIN_NAME = "__NEW_TRAIN__"
local TRAINS_FULL_NAME = "__TRAINS_FULL__"

---@class TDS.Server.DistributionSystem : object
---@field m_queue TDS.Request[]
---@field m_maxTrains integer
---@field m_pause integer
---@field m_trainStacker TDS.Server.TrainStacker
---@field m_databaseAccessLayer TDS.Server.DatabaseAccessLayer
---@field m_logger Core.Logger
---@overload fun(logger: Core.Logger, databaseAccessLayer: TDS.Server.DatabaseAccessLayer) : TDS.Server.DistributionSystem
local DistributionSystem = {}

---@private
---@param logger Core.Logger
---@param databaseAccessLayer TDS.Server.DatabaseAccessLayer
function DistributionSystem:__init(logger, databaseAccessLayer)
    self.m_queue = {}
    self.m_pause = 0

    --//TODO: count connected block signals
    self.m_maxTrains = 10

    self.m_trainStacker = TrainStacker(ProxyReference(Config.StationId))
    self.m_databaseAccessLayer = databaseAccessLayer
    self.m_logger = logger

    self.m_logger:LogInfo("you can add trains by naming them: " .. NEW_TRAIN_NAME)
end

---@private
---@param train Satis.Train
function DistributionSystem:AddTrain(train)
    local trainObj = self.m_databaseAccessLayer:CreateTrain({ State = "None" })
    train:setName(trainObj.Id:ToString())

    self.m_trainStacker:CallbackTrain(trainObj)
end

function DistributionSystem:Check()
    local connectedStation = self.m_trainStacker:GetStationReference()
    local trackGraph = connectedStation:Get():getTrackGraph()

    local trains = trackGraph:getTrains()
    for _, train in pairs(trains) do
        if train:getName() == NEW_TRAIN_NAME then
            if self.m_databaseAccessLayer:TrainsCount() > self.m_maxTrains then
                computer.attentionPing(computer.getInstance().location)
                computer.textNotification("max trains reached")
                self.m_logger:LogWarning("max trains reached")
                goto continue
            end

            self:AddTrain(train)
        end

        ::continue::
    end
end

---@private
---@param itemName string
---@return TDS.Server.Station | nil
function DistributionSystem:GetLoadStation(itemName)
    for _, station in pairs(self.m_databaseAccessLayer:StationsIterator()) do
        ---@cast station TDS.Server.Station

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

---@private
---@return TDS.Server.Train | nil
function DistributionSystem:GetFreeTrain()
    for _, value in pairs(self.m_databaseAccessLayer:TrainsIterator()) do
        ---@cast value TDS.Server.Train

        if not value:IsValid() then
            self.m_databaseAccessLayer:RemoveTrain(value.Id)
            goto continue
        end

        if value.State == "Idle" then
            return value
        end

        ::continue::
    end
end

function DistributionSystem:Distribute()
    ---@type TDS.Server.Delivery[]
    local deliveries = {}

    for _, value in pairs(self.m_databaseAccessLayer:RequestsIterator()) do
        ---@cast value TDS.Request

        if Utils.Table.Any(deliveries, function(x) return x.ItemName == value.ItemName end) then
            --//TODO: add station to delivery
        end

        local getStation = self:GetLoadStation(value.ItemName)
        if getStation == nil then
            goto continue
        end

        local train = self:GetFreeTrain()
        if train == nil then
            computer.attentionPing(computer.getInstance().location)
            computer.textNotification("no free train")
            self.m_logger:LogWarning("no free train")
            self.m_pause = 5
            return
        end

        local delivery = self.m_databaseAccessLayer:CreateDelivery({
            RequestId = value.Id,
            ItemName = value.ItemName,
            GetStationId = getStation.Id,
            RecieveStationIds = { value.StationId },
            TrainId = train.Id
        })
        table.insert(deliveries, delivery)

        ::continue::
    end

    --//TODO: send deliveries
end

function DistributionSystem:Cycle()
    self:Check()

    if self.m_pause > 0 then
        self.m_pause = self.m_pause - 1
    end
    self:Distribute()
end

return class("TDS.Server.DistributionSystem", DistributionSystem)
