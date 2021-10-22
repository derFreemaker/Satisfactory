local akku = component.proxy("2261ADC047265DCC0058A5825FBA1A56")
local switch = component.proxy("E6938E164E13E21491A3B2A64F1E51C2")
local panel = component.proxy("09B6E642493A6EDD98AF0694D5866AFA")
local leverAuto = panel:getModule(1,8)
local leverMan = panel:getModule(9,8)
local indicatorAuto = panel:getModule(2,8)
local indicatorMan = panel:getModule(8,8)
local indicatorState = panel:getModule(5,10)

print("starting...")
print("")
print(akku)
print(switch)
print(indicatorAuto)
print(indicatorMan)
print(indicatorState)
print(panel)
print(leverAuto)
print(leverMan)
print("")
print("started")

local function setSwitch(bool)
  if bool == true then
    indicatorState:setColor(0,1,0,1)
    switch.isSwitchOn = true
  else
    indicatorState:setColor(1,0,0,1)
    switch.isSwitchOn = false
 end
end

while true do
  if leverAuto.state == true then
    indicatorAuto:setColor(0,1,0,1)
  else
    indicatorAuto:setColor(1,0,0,1)
  end

  if leverMan.state == true then
    indicatorMan:setColor(0,1,0,1)
  else
    indicatorMan:setColor(1,0,0,1)
  end

 if leverAuto.state == true then
  if akku.powerStore < 10 then
    setSwitch(false)
  else
   if akku.powerStore > 10 then
    setSwitch(true)
   end
  end
 else
  if leverMan.state == true then
    setSwitch(true)
  else
    setSwitch(false)
  end
 end
event.pull(0.125)
end