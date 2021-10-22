panel = component.proxy("868378D7483D82D2DE3C86B47215BDEC")

print("--Modules--") 
    loopStationButton = panel:getModule(5, 5)
    trainSelectButton = panel:getModule(5, 9)
    stopTrainSwitch = panel:getModule(6, 10)
    trainSelectPotent = panel:getModule(5, 10)
    trainNumMicroDisplay = panel:getModule(4, 10)
    trainSpeedGuage = panel:getModule(0, 10)
    allTrainStopButton = panel:getModule(10, 10)

    print("loopStationButton:", loopStationButton)
    print("stopTrainSwitch:", stopTrainSwitch)
    print("trainSelectPotent:", trainSelectPotent)
    print("trainSelectButton:", trainSelectButton)
    print("trainNumMicroDisplay:", trainNumMicroDisplay)
    print("trainSpeedGuage:", trainSpeedGuage)
    print("allTrainStopButton:", allTrainStopButton)
print("--Modules--")

trainStation = component.proxy("97FEF4D44C22F600A77E2C8B74C52B44")

event.listen(loopStationButton)
event.listen(trainSelectButton)
addCheck = false
switchSet = false
trainSelectPotentValSave = 1

trainSelectButton:setColor(0.5, 0.5, 0.5, 0.1)
tSelectButtonPressed = false

trainSpeedGuage.limit = 200
trainSpeedGuage.percent = 75

while true do
    e, s = event:pull()
    trackGraph = trainStation:getTrackGraph()
        trains = trackGraph:getTrains()
        stations = trackGraph:getStations()
            for i = 1, #trains do
                timeTables = {trains[i]:getTimeTable()}
                if stations[i].name == "Looping Station" then
                    loopStation = stations[i]
                end
            end
    

    if s == loopStationButton then
        print("buttonPressed")
        for i = 1, #trains do
            if trains[i]:getTimeTable().numStops == 1 and addCheck == false then
                timeTables[i]:addStop(1, loopStation, 0.1)
                loopStationButton:setColor(0, 1, 0, 0.5)
                print("added")
                addCheck = true
            elseif timeTables.numStops ~= 1 and addCheck == false then
                loopStationButton:setColor(1, 0, 0, 0.5)
                print("none added")
                addCheck = true
            end
         end
    end

addCheck = false
--TrainSelectSystem

    targetedTrainNum = trainSelectPotent.value
    tragetedTrain =  trains[targetedTrainNum]

    if s == trainSelectPotent then
        trainSelectPotent.max = #trains
        --print("trainSelectPotentiometer Max Value:", trainSelectPotent.max)
    end

    if s == trainSelectButton then

        selectedTrainNum = targetedTrainNum
        selectedTrain = trains[selectedTrainNum]
        print("Selected Train:", selectedTrain:getName())
        trainNumMicroDisplay:setText(selectedTrainNum)
        
        stopTrainSwitch.state = selectedTrain.isSelfDrivng
        
        tSelectButtonPressed = true
    end

    if tSelectButtonPressed == true then
        if s == stopTrainSwitch then
            selectedTrain:setSelfDriving(stopTrainSwitch.state)
            print("Train Stop Switch State =", stopTrainSwitch.state)
        end

        if selectedTrain.isSelfDriving == true then
            trainSelectButton:setColor(0, 1, 0, 0.5)
        else
            trainSelectButton:setColor(1, 0, 0, 0.5)
        end
    end
--Speed
    

end