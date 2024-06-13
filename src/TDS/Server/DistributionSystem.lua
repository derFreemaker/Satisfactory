local UUID = require("Core.Common.UUID")
local Path = require("Core.FileSystem.Path")
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

---@param uuidStr string
---@return fun() : Satis.RailroadStation | nil
local function stationRefFetch(uuidStr)
    return function()
        ---@type Satis.RailroadStation
        local connectedStation = component.proxy(Config.StationId)
        if not connectedStation then
            error("Config.StationId is invalid or was not found")
        end

        local stations = connectedStation:getTrackGraph():getStations()
        for _, station in pairs(stations) do
            if station.name == uuidStr then
                return station
            end
        end
    end
end

function DistributionSystem:Check()
    --//TODO: check for missing stations or trains

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
        train:setName(uuid:ToString())

        self.m_trains:Set(uuid:ToString(), Train(uuid, 1))

        ::continue::
    end

    local stations = trackGraph:getStations()
    for _, station in pairs(stations) do
        if station.name ~= NEW_NAME then
            goto continue
        end

        local uuid = UUID.Static__New()
        station.name = uuid:ToString()

        --//TODO: add station

        ::continue::
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
