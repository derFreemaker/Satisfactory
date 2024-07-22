---@class TDS.Server.TrainStacker : object
---@field m_baseStation Core.Ref<Satis.RailroadStation>
---@overload fun(station: Core.Ref<Satis.RailroadStation>) : TDS.Server.TrainStacker
local TrainStacker = {}

---@private
---@param station Core.Ref<Satis.RailroadStation>
function TrainStacker:__init(station)
    self.m_baseStation = station
end

---@return Core.Ref<Satis.RailroadStation>
function TrainStacker:GetStationReference()
    return self.m_baseStation
end

---@param train TDS.Server.Train
function TrainStacker:CallbackTrain(train)
    local trainRef = train:GetRef():Get()

    local newTimeTable = trainRef:newTimeTable():await()
    newTimeTable:addStop(0, self.m_baseStation:Get())

    train.State = "Traveling"
    trainRef:setSelfDriving(true)
end

---@param train TDS.Server.Train
---@param getStation TDS.Server.Station
---@param recieveStations TDS.Server.Station[]
function TrainStacker:SendTrain(train, getStation, recieveStations)
    local trainRef = train:GetRef():Get()

    local trainTimeTable = trainRef:newTimeTable():await()
    trainTimeTable:addStop(0, getStation:GetRef():Get())
    for i = 1, #recieveStations do
        trainTimeTable:addStop(i, recieveStations[i]:GetRef():Get())
    end
    trainTimeTable:addStop(#recieveStations + 1, self.m_baseStation:Get())

    train.State = "Working"
    trainRef:setSelfDriving(true)
end

return class("TDS.Server.TrainStacker", TrainStacker)
