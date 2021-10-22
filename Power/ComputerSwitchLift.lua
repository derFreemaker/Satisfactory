local akkuLift = component.proxy("26BAC4CD47B15ECB112662A84702708E")
local akkuMain = component.proxy("F211BC434D9D64A2370777A4D59837BA")
local switchLift = component.proxy("68912CFB4D26248D0D6287A95F4D7CF8")
local switchMain = component.proxy("9F7AD3934D38B3B9B6DBEEA8E4454E61")
local switchMainControlTower = component.proxy("C1D991A34B4B2F05354E72BEA8C469EB")

print(akkuLift)
print(akkuMain)
print(switchLift)
print(switchMain)
print(switchMainControlTower)

local last = true


while true do
    if akkuLift.batteryStatus == 4 and last == true then
        switchLift.isSwitchOn = false
        last = false
        print("false")
    end

    if last == false then
        if akkuMain.batteryStatus == 2 or akkuMain.batteryStatus == 3 then
            if switchMain.isSwitchOn == true and switchMainControlTower.isSwitchOn == true then
                switchLift.isSwitchOn = true
                last = true
                print("true")
            end
        end
    end
    event.pull(0.125)
end