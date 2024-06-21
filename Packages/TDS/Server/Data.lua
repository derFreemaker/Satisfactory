local Data={
["TDS.Server.__main"] = [==========[
local EventPullAdapter = require("Core.Event.EventPullAdapter")

local DistributionSystem = require("TDS.Server.DistributionSystem")

---@class TDS.Server.Main : Github_Loading.Entities.Main
---@field m_distibutionSystem TDS.Server.DistributionSystem
local Main = {}

function Main:Configure()
    if not Config.StationId then
        computer.panic("Config.StationId was not set")
    end

    -- add host to host endpoints

    self.m_distibutionSystem = DistributionSystem(self.Logger:subLogger("TrainDistributionSystem"))
end

function Main:Run()
	while true do
        EventPullAdapter:Wait(2)

        self.m_distibutionSystem:Run()
	end
end

return Main

]==========],
["TDS.Server.DatabaseAccessLayer"] = [==========[
local Path = require("Core.FileSystem.Path")
local DbTable = require("Database.DbTable")

---@class TDS.Server.DatabaseAccessLayer : object
---@overload fun(logger: Core.Logger) : TDS.Server.DatabaseAccessLayer
local DatabaseAccessLayer = {}

---@private
---@param logger Core.Logger
function DatabaseAccessLayer:__init(logger)
    self.m_trains = DbTable(Path("/Database/Trains"), logger:subLogger("Trains_DbTable"))
    self.m_stations = DbTable(Path("/Database/Stations"), logger:subLogger("Stations_DbTable"))
    self.m_requests = DbTable(Path("/Database/Requests"), logger:subLogger("Requests_DbTable"))
end

--//TODO: add functions

return class("TDS.Server.DatabaseAccessLayer", DatabaseAccessLayer)

]==========],
["TDS.Server.DistributionSystem"] = [==========[
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

]==========],
["TDS.Server.TrainHandler"] = [==========[
local UUID = require("Core.Common.UUID")

---@class TDS.TrainHandler : object
---@overload fun() : TDS.TrainHandler
local TrainHandler = {}

---@private
function TrainHandler:__init()
    
end

function TrainHandler:Handle()

end

return class("TDS.TrainHandler", TrainHandler)

]==========],
["TDS.Server.Entities.Station"] = [==========[
local CustomReference = require("Core.References.CustomReference")

---@class TDS.Server.Entities.Station : object, Core.Json.Serializable
---@field Id Core.UUID
---@field ItemName string
---@overload fun(id: Core.UUID) : TDS.Server.Entities.Station
local Station = {}

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

---@return Core.Reference<Satis.RailroadStation>
function Station:GetRef()
    return CustomReference(stationRefFetch(self.Id:ToString()))
end

return class("TDS.Server.Entities.Station", Station,
    { Inherit = require("Core.Json.Serializable") })

]==========],
["TDS.Server.Entities.Train"] = [==========[
local CustomReference = require("Core.References.CustomReference")

---@alias TDS.Server.Entities.Train.State
---|"None"
---|"Traveling"
---|"Idle"
---|"Working"

---@class TDS.Server.Entities.Train : object, Core.Json.Serializable
---@field Id Core.UUID
---@field State TDS.Server.Entities.Train.State
---@overload fun(id: Core.UUID, state: TDS.Server.Entities.Train.State) : TDS.Server.Entities.Train
local Train = {}

---@param id Core.UUID
---@param state TDS.Server.Entities.Train.State
function Train:__init(id, state)
    self.Id = id
    self.State = state
end

---@param uuidStr string
---@return fun() : Satis.Train | nil
local function trainRefFetch(uuidStr)
    return function()
        ---@type Satis.RailroadStation
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

---@return Core.Reference<Satis.Train>
function Train:GetRef()
    return CustomReference(trainRefFetch(self.Id:ToString()))
end

function Train:Serialize()
    return self.Id, self.State
end

return class("TDS.Entities.Train", Train,
    { Inherit = require("Core.Json.Serializable") })

]==========],
}

return Data
