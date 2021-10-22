--Network Card
local network = computer.getPCIDevices(findClass("NetworkCard"))[1]
--Network Card

local Power = {
    Prozent = "",
    TimeFull = "",
    TimeEmpty = "",
    Charchging = ""
}

local function Send()
    network.send(network, "EAE21CA74C17FEFAB3EA578AB25EEA02", 1325, "Data", "EnergyCheckMain", "", "set:"..Power.Prozent..","..Power.TimeFull..","..Power.TimeEmpty..","..Power.Charchging, "", "CheckMainEnergyComputer", "")
end

local gpu = computer.getPCIDevices(findClass("GPUT1"))[1]

if not gpu then
error("No GPU T1 found!")
end

local checkBattery = component.proxy("F211BC434D9D64A2370777A4D59837BA")
local screen = component.proxy("1E5E160E45A58B3E8F38D59864395F60")

local textX = 2
local textY = 0
gpu:bindScreen(screen)
local w, h = gpu:getSize()

gpu:setSize(9, 2)


while true do

local tUF = checkBattery.timeUntilFull
  local tUFH = tUF / 3600
  local tUFM = math.fmod(tUFH, 1) * 60
  local tUFS = math.fmod(tUFM, 1) * 60
   local tUFHR = math.floor(tUFH)
   local tUFMR = math.floor(tUFM)
   local tUFSR = math.floor(tUFS)
    local tUFSt = tUFHR..":"..tUFMR..":"..tUFSR
     if string.len(tUFSt) == 9 then --nothing
     elseif string.len(tUFSt) == 8 then tUFSt = " "..tUFHR..":"..tUFMR..":"..tUFSR 
     elseif string.len(tUFSt) == 7 then tUFSt = "  "..tUFHR..":"..tUFMR..":"..tUFSR end
 

local tUE = checkBattery.timeUntilEmpty
 local tUEH = tUE / 3600
 local tUEM = math.fmod(tUEH, 1) * 60
 local tUES = math.fmod(tUEM, 1) * 60
  local tUEHR = math.floor(tUEH)
  local tUEMR = math.floor(tUEM)
  local tUESR = math.floor(tUES)
   local tUESt = tUEHR..":"..tUEMR..":"..tUESR
    if string.len(tUESt) == 9 then --nothing
    elseif string.len(tUESt) == 8 then tUESt = " "..tUEHR..":"..tUEMR..":"..tUESR 
    elseif string.len(tUESt) == 7 then tUESt = "  "..tUEHR..":"..tUEMR..":"..tUESR end

local powerStore = checkBattery.PowerStore
local powerStoreR = math.floor(checkBattery.PowerStore+0.5)
local batteryStatus = checkBattery.batteryStatus
gpu:setText(0, 0, "              ") 
gpu:setText(0, 1, "              ") 

   
if batteryStatus == 0 then gpu:setText(textX, 0, powerStoreR .. "%" .. "-") gpu:setText(0, 1, "---:--:--") end

if batteryStatus == 1 then gpu:setText(textX, 0, powerStoreR .. "%" .. "-") gpu:setText(0, 1, "---:--:--") end

if batteryStatus == 2 then gpu:setText(textX, 0, powerStoreR .. "%" .. "-") gpu:setText(0, 1, "---:--:--") end

if batteryStatus == 3 then gpu:setText(textX, 0, powerStoreR .. "%" .. "^") gpu:setText(0, 1, tUFSt) end

if batteryStatus == 4 then gpu:setText(textX, 0, powerStoreR .. "%" .. "V") gpu:setText(0, 1, tUESt) end

gpu:flush()
Send()
event.pull(0.25)
end

