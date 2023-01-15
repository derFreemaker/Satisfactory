local panel = component.proxy("868378D7483D82D2DE3C86B47215BDEC")

print("--Modules--") 
    local loopStationButton = panel:getModule(5, 5)
    local trainSelectButton = panel:getModule(5, 9)
    local stopTrainSwitch = panel:getModule(6, 10)
    local trainSelectPotent = panel:getModule(5, 10)
    local trainNumMicroDisplay = panel:getModule(4, 10)
    local trainSpeedGuage = panel:getModule(0, 10)
    local allTrainStopButton = panel:getModule(10, 10)

    print("loopStationButton:", loopStationButton)
    print("stopTrainSwitch:", stopTrainSwitch)
    print("trainSelectPotent:", trainSelectPotent)
    print("trainSelectButton:", trainSelectButton)
    print("trainNumMicroDisplay:", trainNumMicroDisplay)
    print("trainSpeedGuage:", trainSpeedGuage)
    print("allTrainStopButton:", allTrainStopButton)
print("--Modules--")

local trainStation = component.proxy("97FEF4D44C22F600A77E2C8B74C52B44")

event.listen(loopStationButton)
event.listen(trainSelectButton)
event.listen(allTrainStopButton)
local addCheck = false
local switchSet = false
local trainSelectPotentValSave = 1

trainSelectButton:setColor(0.5, 0.5, 0.5, 0.1)
local tSelectButtonPressed = false

trainSpeedGuage.limit = 150

local LoopStation, SelectedTrain, TimeTable
local defaltLoopStationRules = {
    definition = 0,
    duration = 0.1,
    isDurationAndRule = false,
    loadFilters = {},
    unloadFilters = {}
}
local success, result

local function addStop(timeTable, index, station, ruleSet)
    return timeTable:addStop(index, station, ruleSet)
end

local function setSelfDriving(train, state)
    train:setSelfDriving(state)
end

local function lsa (trains)
    print("LSA Process started")
    local added = 0
    for i = 1, #trains do
        TimeTable = trains[i]:getTimeTable()
        print(trains[i]:getName()..":"..TimeTable.numStops)
        if TimeTable.numStops == 1 then
            success, result = pcall(addStop, TimeTable, 1, LoopStation, defaltLoopStationRules)
            if success then
                if result then
                    print("Added Looping Station to Train: "..trains[i]:getName())
                end
                added = added + 1
            else
                print("failed to add Looping Station to Timetable of Train: "..trains[i]:getName().." with Error: "..result)
            end
        end
    end
    if added >= 1 then
        print("added: "..added)
        loopStationButton:setColor(0, 1, 0, 0.5)
    else
        print("none added")
        loopStationButton:setColor(1, 0, 0, 0.5)
    end
end

while true do
    local e, s = event:pull()
    local trackGraph = trainStation:getTrackGraph()
        local trains = trackGraph:getTrains()
        local stations = trackGraph:getStations()
            for i = 1, #trains do
                TimeTable = trains[i]:getTimeTable()
                if stations[i].name == "Looping Station" then
                    LoopStation = stations[i]
                end
            end
if s == loopStationButton then
    success, result = pcall(lsa, trains)
    if not success then print("LSA failed: "..result) end
end

--TrainSelectSystem

    local targetedTrainNum = trainSelectPotent.value
    local tragetedTrain =  trains[targetedTrainNum]

    if s == trainSelectPotent then
        trainSelectPotent.max = #trains
    end

    if s == trainSelectButton then

        local selectedTrainNum = targetedTrainNum
        SelectedTrain = trains[selectedTrainNum]
        print("Selected Train:", SelectedTrain:getName())
        trainNumMicroDisplay:setText(selectedTrainNum)
        
        stopTrainSwitch.state = SelectedTrain.isSelfDrivng
        
        tSelectButtonPressed = true
    end

    if tSelectButtonPressed == true then
        if s == stopTrainSwitch then
            success, result = pcall(setSelfDriving, SelectedTrain, stopTrainSwitch.state)
            if not success then print("failed to set SelfDriving on Train: " .. SelectedTrain:getName().." with Error: "..result) end
        end
        
        trainSpeedGuage.percent = SelectedTrain:getFirst():getMovement().speed/7500
    
        if SelectedTrain.isSelfDriving == true then
            trainSelectButton:setColor(0, 1, 0, 0.5)
        else
            trainSelectButton:setColor(1, 0, 0, 0.5)
        end
    end
--StopAll

    if s == allTrainStopButton then
        for i = 1, #trains do
            success, result = pcall(setSelfDriving, trains[i], not trains[i].isSelfDriving)
            if not success then print("failed to set Self Driving by Train: "..trains[i]:getName().." with Error: "..result) end
        end
    end
end