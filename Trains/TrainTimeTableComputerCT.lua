local gpu = computer.getPCIDevices(findClass("GPUT1"))[1]
if not gpu then
error("No GPU T1 found!")
end

local screen = component.proxy("33ED1407445A7F31021FCF90C1F79FFA")
gpu:bindScreen(screen)
local scWidth, scHeight = gpu:getSize()

--gpu:setBackground(0, 0, 0, 1)
gpu:setForeground(0.75, 0.1, 0, 1)

local trainStation = component.proxy("97FEF4D44C22F600A77E2C8B74C52B44")

while true do
    local trains = trainStation:getTrackGraph():getTrains()

    local trainTimeTable = {}

    gpu:fill(0,0,scWidth, scHeight, " ")
    --print(trainTimeTable)
    if scHeight >= (#trains+2) then
    gpu:setSize(104, 25) else
    gpu:setSize(104, #trains+2) end

    for i = 1, #trains do
        local h = i+1

        table.insert(trainTimeTable, trains[i]:getName())
        
        local xP = 2
        gpu:setText(xP,0, "Nr.")
        gpu:setText(xP,h, i)

        xP = 6
        gpu:setText(xP,0, "Train")
        if trainTimeTable[i] ~= "" then
        gpu:setText(xP,h, trainTimeTable[i])
        else
        gpu:setText(xP,h, "Unnamed")
        end

        xP = 32
        gpu:setText(xP, 0, "Next Station")
        if trains[i].isSelfDriving and trains[i].hasTimeTable then
            gpu:setText(xP, h, trains[i]:getTimeTable():getStop(trains[i]:getTimeTable():getCurrentStop()).station.name)
        else gpu:setText(xP, h, "-----------")
        end

        xP = 58
        gpu:setText(xP, 0, "Dock State")
        if trains[i].isDocked then
        gpu:setText(xP, h, "Docked")
        else gpu:setText(xP,h, "not Docked")
        end
        
        xP = 74
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
        
        xP = 89
        gpu:setText(xP, 0, "Speed".." (km/h)")
        gpu:setText(xP, h, math.floor(trains[i]:getFirst():getMovement().speed/25))

    end

    gpu:flush()
    event.pull(0.25)

end