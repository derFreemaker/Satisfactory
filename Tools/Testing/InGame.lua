---@type Satis.RailroadStation
local station = component.proxy("")

local platformCargo = station:getConnectedPlatform(0)
---@cast platformCargo Satis.TrainPlatformCargo

print(platformCargo.standby)
platformCargo.standby = true
print(platformCargo.standby)
