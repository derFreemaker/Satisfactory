local gpu = computer.getPCIDevices(findClass("GPUT1"))[1]
if not gpu then
error("No GPU T1 found!")
end

local screen = component.proxy("33ED1407445A7F31021FCF90C1F79FFA")
gpu:bindScreen(screen)
local scWidth, scHeight = gpu:getSize()

gpu:setBackground(0, 0, 0, 1)
gpu:setForeground(0.75, 0.1, 0, 1)

trainStation = component.proxy("97FEF4D44C22F600A77E2C8B74C52B44")
    trackGraph = trainStation:getTrackGraph()

while true do
    trains = trackGraph:getTrains()
    stations = trackGraph:getStations()

    trainTimeTable = {}

    gpu:fill(0,0,scWidth, scHeight, " ")
    --print(trainTimeTable)
    if scHeight >= (#trains+2) then
    gpu:setSize(99, 23) else
    gpu:setSize(99, #trains+2) end

    for i = 1, #trains do
        h = i+1

        table.insert(trainTimeTable, trains[i]:getName())
        
        xP = 2
        gpu:setText(xP,0, "Train")
        if trainTimeTable[i] ~= "" then
        gpu:setText(xP,h, trainTimeTable[i])
        else
        gpu:setText(xP,h, "Unnamed")
        end

        xP = 28
        gpu:setText(xP, 0, "Next Station")
        if trains[i].isSelfDriving and trains[i].hasTimeTable then
            gpu:setText(xP, h, trains[i]:getTimeTable():getStop(trains[i]:getTimeTable():getCurrentStop()).station.name)
        else gpu:setText(xP, h, "-----------")
        end

        xP = 54
        gpu:setText(xP, 0, "Dock State")
        if trains[i].isDocked then
        gpu:setText(xP, h, "Docked")
        else gpu:setText(xP,h, "not Docked")
        end
        
        xP = 70
        gpu:setText(xP, 0, "State")
        if trains[i].selfDrivingError == 0 then
            gpu:setText(xP,h, "Functional")
        elseif trains[i].selfDrivingError == 1 then
            gpu:setText(xP,h, "No Power")
        elseif trains[i].selfDrivingError == 2 then
            gpu:setText(xP,h, "No Time Table")
        elseif trains[i].selfDrivingError == 3 then
            gpu:setText(xP,h, "Invalid Next Stop")
        elseif trains[i].selfDrivingError == 4 then
            gpu:setText(xP,h, "Invalid Train Placement")
        elseif trains[i].selfDrivingError == 5 then
            gpu:setText(xP,h, "No Path")
        end
        
        xP = 85
        gpu:setText(xP, 0, "Speed".." (km/h)")
        gpu:setText(xP, h, math.floor(trains[i]:getFirst():getMovement().speed/50))

    end

    gpu:flush()
    event.pull(0.5)
    
end