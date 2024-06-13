local CustomReference = require("Core.References.CustomReference")

---@class TDS.Server.Entities.Station : object, Core.Json.Serializable
---@field Id Core.UUID
---@field ItemName string
---@overload fun(id: Core.UUID) : TDS.Server.Entities.Station
local Station = {}

---@param uuidStr string
---@return fun() : Satis.RailroadStation | nil
local function stationRefFetch(uuidStr)
    return function()
        ---@type Satis.RailroadStation
        local connectedStation = component.proxy(Config.StationId)
        if not connectedStation then
            error("Config.StationId is invalid or was not found")
        end

        local stations = connectedStation:getTrackGraph():getStations()
        for _, station in pairs(stations) do
            if station.name == uuidStr then
                return station
            end
        end
    end
end

---@return Core.Reference<Satis.RailroadStation>
function Station:GetRef()
    return CustomReference(stationRefFetch(self.Id:ToString()))
end

return class("TDS.Server.Entities.Station", Station,
    { Inherit = require("Core.Json.Serializable") })
