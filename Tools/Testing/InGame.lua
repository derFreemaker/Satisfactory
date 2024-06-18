---@type Satis.Build_RailroadBlockSignal_C
local signals = {}
for i, uuid in pairs(component.findComponent(classes.Build_RailroadBlockSignal_C)) do
    signals[i] = component.proxy(uuid)
end

---@type Satis.RailroadStation
local stationOut = component.proxy("7BA7244D4A8F1FDBDBC0C9A587DB24D4")

---@type Satis.RailroadStation
local stationRandom = component.proxy("DFE572444EBCE503905F1BB00F911F6A")

local trains = stationOut:getTrackGraph():getTrains()
local timeTableFuture = trains[1]:newTimeTable()
local timeTable = timeTableFuture:await()
trains[1]:setSelfDriving(true)

timeTable:addStop(0, stationRandom, structs.TrainDockingRuleSet({0, 0 , false}))
timeTable:addStop(1, stationOut, structs.TrainDockingRuleSet({0, 0 , false}))
print("done")

while true do
    local currentStop = timeTable:getCurrentStop()

    if currentStop == 2 then
        print("going out")
    end
end
