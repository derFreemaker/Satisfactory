local UUID = require("Core.Common.UUID")
local Path = require("Core.FileSystem.Path")
local DbTable = require("Core.Database.Table")

local Train = require("TDS.Server.Entities.Train")
local Station = require("TDS.Server.Entities.Station")
local Delivery = require("TDS.Server.Entities.Delivery")

local Request = require("TDS.Core.Entities.Request")

---@class TDS.Server.DatabaseAccessLayer : object
---@field m_trains Core.Database.Table<string, TDS.Server.Train>
---@field m_stations Core.Database.Table<string, TDS.Server.Station>
---@field m_deliveries Core.Database.Table<string, TDS.Server.Delivery>
---@field m_requests Core.Database.Table<string, TDS.Request>
---@overload fun(logger: Core.Logger) : TDS.Server.DatabaseAccessLayer
local DatabaseAccessLayer = {}

---@private
---@param logger Core.Logger
function DatabaseAccessLayer:__init(logger)
    self.m_trains = DbTable(Path("/Database/Trains"), logger:subLogger("Trains_DbTable"))
    self.m_stations = DbTable(Path("/Database/Stations"), logger:subLogger("Stations_DbTable"))
    self.m_deliveries = DbTable(Path("/Database/Deliveries"), logger:subLogger("Deliveries_DbTable"))
    self.m_requests = DbTable(Path("/Database/Requests"), logger:subLogger("Requests_DbTable"))

    self.m_trains:Load()
    self.m_stations:Load()
    self.m_deliveries:Load()
    self.m_requests:Load()
end

function DatabaseAccessLayer:Save()
    self.m_trains:Save()
    self.m_stations:Save()
    self.m_deliveries:Save()
    self.m_requests:Save()
end

--------------------------------------------------------------
-- Trains
--------------------------------------------------------------

---@param createTrain TDS.Server.Train.Create
---@return TDS.Server.Train
function DatabaseAccessLayer:CreateTrain(createTrain)
    local train = Train(UUID.Static__New(), createTrain.State)

    train = self.m_trains:Add(train.Id:ToString(), train)
    return train
end

---@param id Core.UUID
---@return boolean
function DatabaseAccessLayer:RemoveTrain(id)
    return self.m_trains:Remove(id:ToString())
end

---@param id Core.UUID
---@return TDS.Server.Train
function DatabaseAccessLayer:GetTrain(id)
    return self.m_trains:Get(id:ToString())
end

---@return Core.Database.Iterator
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

---@param createStation TDS.Server.Station.Create
---@return TDS.Server.Station
function DatabaseAccessLayer:CreateStation(createStation)
    local station = Station(UUID.Static__New(), createStation.ItemName)

    station = self.m_stations:Add(station.Id:ToString(), station)
    return station
end

---@param id Core.UUID
---@return boolean
function DatabaseAccessLayer:RemoveStation(id)
    return self.m_stations:Remove(id:ToString())
end

---@param id Core.UUID
---@return TDS.Server.Station
function DatabaseAccessLayer:GetStation(id)
    return self.m_stations:Get(id:ToString())
end

---@return Core.Database.Iterator
function DatabaseAccessLayer:StationsIterator()
    return self.m_stations:Iterator()
end

--------------------------------------------------------------
-- Request
--------------------------------------------------------------

---@param createRequest TDS.Request.Create
---@return TDS.Request
function DatabaseAccessLayer:CreateRequest(createRequest)
    local request = Request(UUID.Static__New(), createRequest.StationId, createRequest.Item)

    request = self.m_requests:Add(request.Id:ToString(), request)
    return request
end

---@param id Core.UUID
---@return boolean
function DatabaseAccessLayer:RemoveRequest(id)
    return self.m_requests:Remove(id:ToString())
end

---@return Core.Database.Iterator
function DatabaseAccessLayer:RequestsIterator()
    return self.m_requests:Iterator()
end

--------------------------------------------------------------
-- Delivery
--------------------------------------------------------------

---@param createDelivery TDS.Server.Delivery.Create
function DatabaseAccessLayer:CreateDelivery(createDelivery)
    local delivery = Delivery(UUID.Static__New(), createDelivery.ItemName, createDelivery.GetStationId, createDelivery.RecieveStationIds)

    delivery = self.m_deliveries:Add(delivery.Id:ToString(), delivery)
    return delivery
end

---@param id Core.UUID
---@return boolean
function DatabaseAccessLayer:RemoveDelivery(id)
    return self.m_deliveries:Remove(id:ToString())
end

---@return Core.Database.Iterator
function DatabaseAccessLayer:DeliveryIterator()
    return self.m_deliveries:Iterator()
end

return class("TDS.Server.DatabaseAccessLayer", DatabaseAccessLayer)
