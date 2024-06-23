local UUID = require("Core.Common.UUID")
local Path = require("Core.FileSystem.Path")
local DbTable = require("Database.DbTable")

local Train = require("TDS.Server.Entities.Train")
local Station = require("TDS.Server.Entities.Station")
local Request = require("TDS.Core.Entities.Request")

---@class TDS.Server.DatabaseAccessLayer : object
---@field m_trains Database.DbTable<string, TDS.Server.Entities.Train>
---@field m_stations Database.DbTable<string, TDS.Server.Entities.Station>
---@field m_requests Database.DbTable<string, TDS.Entities.Request>
---@overload fun(logger: Core.Logger) : TDS.Server.DatabaseAccessLayer
local DatabaseAccessLayer = {}

---@private
---@param logger Core.Logger
function DatabaseAccessLayer:__init(logger)
    self.m_trains = DbTable(Path("/Database/Trains"), logger:subLogger("Trains_DbTable"))
    self.m_stations = DbTable(Path("/Database/Stations"), logger:subLogger("Stations_DbTable"))
    self.m_requests = DbTable(Path("/Database/Requests"), logger:subLogger("Requests_DbTable"))

    self.m_trains:Load()
    self.m_stations:Load()
    self.m_requests:Load()
end

function DatabaseAccessLayer:Save()
    self.m_trains:Save()
    self.m_stations:Save()
    self.m_requests:Save()
end

--------------------------------------------------------------
-- Trains
--------------------------------------------------------------

---@param createTrain TDS.Server.Entities.Train.Create
---@return TDS.Server.Entities.Train
function DatabaseAccessLayer:CreateTrain(createTrain)
    local train = Train(UUID.Static__New(), createTrain.State)

    self.m_trains:Add(train.Id:ToString(), train)
    return train
end

---@param uuid Core.UUID
---@return boolean
function DatabaseAccessLayer:RemoveTrain(uuid)
    return self.m_trains:Remove(uuid:ToString())
end

---@return Database.Iterator
function DatabaseAccessLayer:TrainsIterator()
    return self.m_trains:Iterator()
end

---@return integer
function DatabaseAccessLayer:TrainsCount()
    return self.m_trains:Count()
end

--------------------------------------------------------------
-- Stations
--------------------------------------------------------------

---@param createStation TDS.Server.Entities.Station.Create
---@return TDS.Server.Entities.Station
function DatabaseAccessLayer:CreateStation(createStation)
    local station = Station(UUID.Static__New(), createStation.ItemName)

    self.m_stations:Add(station.Id:ToString(), station)
    return station
end

---@param uuid Core.UUID
---@return boolean
function DatabaseAccessLayer:RemoveStation(uuid)
    return self.m_stations:Remove(uuid:ToString())
end

---@return Database.Iterator
function DatabaseAccessLayer:StationsIterator()
    return self.m_stations:Iterator()
end

--------------------------------------------------------------
-- Request
--------------------------------------------------------------

---@param createRequest TDS.Entities.Request.Create
---@return TDS.Entities.Request
function DatabaseAccessLayer:CreateRequest(createRequest)
    local request = Request(UUID.Static__New(), 1, nil, createRequest.Item)

    self.m_requests:Add(request.Id:ToString(), request)
    return request
end

---@param uuid Core.UUID
---@return boolean
function DatabaseAccessLayer:RemoveRequest(uuid)
    return self.m_requests:Remove(uuid:ToString())
end

function DatabaseAccessLayer:RequestsIterator()
    return self.m_requests:Iterator()
end

return class("TDS.Server.DatabaseAccessLayer", DatabaseAccessLayer)
