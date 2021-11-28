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

local LoopStation
local SelectedTrain
local TimeTable

local function lsa (s, trains)
    if s == loopStationButton then
        print("buttonPressed")
        for i = 1, #trains do
            if TimeTable.numStops == 1 then
                if pcall(TimeTable:addStop(), 1, LoopStation, 0.1) then
                    loopStationButton:setColor(0, 1, 0, 0.5)
                    print("added")
                else
                    print("Fail to add Looping Station to Timetable ")
                end
            elseif TimeTable.numStops ~= 1 then
                loopStationButton:setColor(1, 0, 0, 0.5)
                print("none added")
            end
         end
    end
end

local function setSelfDriving(train, state)
    train:setSelfDriving(state)
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

if pcall(lsa, s, trains) then
 --no action
else
 print("LSA Fail")
end

--TrainSelectSystem

    local targetedTrainNum = trainSelectPotent.value
    local tragetedTrain =  trains[targetedTrainNum]

    if s == trainSelectPotent then
        trainSelectPotent.max = #trains
        --print("trainSelectPotentiometer Max Value:", trainSelectPotent.max)
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
            if pcall(setSelfDriving, SelectedTrain, stopTrainSwitch.state) then
                print("Train Stop Switch State =", stopTrainSwitch.state)
            else
                print("Fail by setting SelfDriving on Train: " .. SelectedTrain:getName())
            end
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
            if pcall(setSelfDriving, trains[i], not trains[i].isSelfDriving) then
                --no action
            else
                print("Swiching failed on Train: ".. trains[i]:getName())
            end
        end
    end
end