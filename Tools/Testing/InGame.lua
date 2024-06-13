---@type Satis.RailroadStation
local station = component.proxy("C6AEE2824F9F77CEF001C5BDF714954D")
local train = station:getTrackGraph():getTrains()[1]
print(#train:getLast():getInventories())
