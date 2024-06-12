local UUID = require("Core.Common.UUID")
local Path = require("Core.FileSystem.Path")
local CustomReference = require("Core.References.CustomReference")
local DbTable = require("Database.DbTable")

local Train = require("TDS.Server.Entities.Train")
local Request = require("TDS.Core.Entities.Request")

NEW_NAME = "NEW_TRAIN"

---@class TDS.Server.DistributionSystem : object
---@field m_queue TDS.Request[]
---@field m_trains Database.DbTable
---@field m_requests Database.DbTable
---@field m_logger Core.Logger
---@overload fun(logger: Core.Logger) : TDS.Server.DistributionSystem
local DistributionSystem = {}

---@private
---@param logger Core.Logger
function DistributionSystem:__init(logger)
    self.m_trains = DbTable(Path("/Trains"), logger:subLogger("Trains_DbTable"))
    self.m_requests = DbTable(Path("/Requests"), logger:subLogger("Requests_DbTable"))

    self.m_logger = logger
end

function DistributionSystem:Save()
    self.m_trains:Save()
end

---@private
---@param requestData TDS.Request.Data
---@return TDS.Request
function DistributionSystem:AddRequest(requestData)
    local request = Request(UUID.Static__New(), 1, nil, requestData)
    self.m_requests:Set(request.Id:ToString(), request)
    return request
end

---@private
---@param trainRef Core.Reference<Satis.Train>
function DistributionSystem:AddTrain(trainRef)
    --//TODO: maybe works to find out if it has fluid containers but should test out
    local lastPart = trainRef:Get():getLast()
    local isFluid = #lastPart:getInventories() == 0

    local train = Train(UUID.Static__New(), 1, isFluid)
    trainRef:Get():setName(train.Id:ToString())

    self.m_trains:Set(train.Id:ToString(), train)
end

---@param uuidStr string
local function trainRefFetch(uuidStr)
    return function()
        ---@type Satis.TrainPlatform
        local connectedStation = component.proxy(Config.StationId)
        if not connectedStation then
            error("Config.StationId is invalid or was not found")
        end

        local trains = connectedStation:getTrackGraph():getTrains()
        for _, train in pairs(trains) do
            if train:getName() == uuidStr then
                return train
            end
        end
    end
end

---@param uuidStr string
local function stationRefFetch(uuidStr)
    return function()
        ---@type Satis.TrainPlatform
        local connectedStation = component.proxy(Config.StationId)
        if not connectedStation then
            error("Config.StationId is invalid or was not found")
        end

        local stations = connectedStation:getTrackGraph():getStations()
        for _, station in pairs(stations) do
            if station:getName() == uuidStr then
                return train
            end
        end
    end
end

function DistributionSystem:Check()
    log("TODO: check for missing stations or trians")
    log("TODO: add any stations or trains")


    ---@type Satis.TrainPlatform
    local connectedStation = component.proxy(Config.StationId)
    if not connectedStation then
        error("Config.StationId is invalid or was not found")
    end
    local trackGraph = connectedStation:getTrackGraph()

    local trains = trackGraph:getTrains()
    for _, train in pairs(trains) do
        if train:getName() ~= NEW_NAME then
            goto continue
        end

        local uuid = UUID.Static__New()
        local uuidStr = uuid:ToString()
        train:setName(uuidStr)

        local trainRef = CustomReference(trainRefFetch(uuidStr), train)
        self:AddTrain(trainRef)

        ::continue::
    end

    local stations = trackGraph:getStations()
    for _, station in pairs(stations) do
        ---@cast station Satis.RailroadStation
        local uuidStr = 
        station.name
    end
end

function DistributionSystem:Distribute()
    log("TODO: implement DistributionSystem:Distribute()")
end

function DistributionSystem:Run()
    self:Check()

    self:Distribute()
end

return class("TDS.DistributionSystem", DistributionSystem)
