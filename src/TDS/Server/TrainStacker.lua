local ProxyReference = require("Core.References.ProxyReference")

---@class TDS.Server.TrainStacker : object
---@field m_station Core.Ref<Satis.RailroadStation>
---@overload fun(stationUUID: FIN.UUID) : TDS.Server.TrainStacker
local TrainStacker = {}

---@private
---@param stationUUID FIN.UUID
function TrainStacker:__init(stationUUID)
    self.m_station = ProxyReference(stationUUID)
end

---@return Core.Ref<Satis.RailroadStation>
function TrainStacker:GetStationReference()
    return self.m_station
end

---@param train Core.Ref<Satis.Train>
function TrainStacker:CallbackTrain(train)
    --//TODO: implement callback
end

---@param train Core.Ref<Satis.Train>
---@param loadStation TDS.Server.Entities.Station
---@param unloadStations TDS.Server.Entities.Station[]
function TrainStacker:SendTrain(train, loadStation, unloadStations)
    local trainTimeTable = train:Get():newTimeTable():await()

    trainTimeTable:addStop(0, loadStation:GetRef():Get())
    for i = 1, #unloadStations do
        trainTimeTable:addStop(i, unloadStations[i]:GetRef():Get())
    end
    trainTimeTable:addStop(#unloadStations + 1, self.m_station:Get())
end

return class("TDS.Server.TrainStacker", TrainStacker)
