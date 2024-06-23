local CustomReference = require("Core.References.CustomReference")

---@class TDS.Server.Entities.Station.Create
---@field ItemName string

---@class TDS.Server.Entities.Station : object, Core.Json.Serializable
---@field Id Core.UUID
---@field ItemName string
---@field m_ref Core.Ref<Satis.RailroadStation>
---@overload fun(id: Core.UUID, itemName: string) : TDS.Server.Entities.Station
local Station = {}

---@private
---@param id Core.UUID
---@param itemName string
function Station:__init(id, itemName)
    self.Id = id
    self.ItemName = itemName
end

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

---@return Core.Ref<Satis.RailroadStation>
function Station:GetRef()
    if self.m_ref then
        return self.m_ref
    end

    self.m_ref = CustomReference(stationRefFetch(self.Id:ToString()))
    return self.m_ref
end

---@return boolean
function Station:IsValid()
    --//TODO: find better solution maybe
    return self:GetRef():IsValid()
end

function Station:Serialize()
    return self.Id, self.ItemName
end

return class("TDS.Server.Entities.Station", Station,
    { Inherit = require("Core.Json.Serializable") })
