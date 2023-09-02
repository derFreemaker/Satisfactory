---@type FicsIt_Networks.Components.FINComputerMod.NetworkCard_C
local networkCard = computer.getPCIDevices(findClass("NetworkCard_C"))[1]

for key, value in pairs(networkCard:getComponents(findClass("NetworkCard_C"))) do
    print(key, value)
end