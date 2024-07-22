local CustomReference = require("Core.Reference.CustomReference")

---@class TDS.Server.Station.Create
---@field ItemName string

---@class TDS.Server.Station : object, Core.Json.Serializable
---@field Id Core.UUID
---@field ItemName string
---@field FillState integer
---@field m_ref Core.Ref<Satis.RailroadStation>
---@overload fun(id: Core.UUID, itemName: string) : TDS.Server.Station
local Station = {}

---@private
---@param id Core.UUID
---@param itemName string
---@param fillState integer
function Station:__init(id, itemName, fillState)
    self.Id = id
    self.ItemName = itemName
    self.FillState = fillState
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
    return self:GetRef():IsValid()
end

function Station:Serialize()
    return self.Id, self.ItemName, self.FillState
end

return class("TDS.Server.Entities.Station", Station,
    { Inherit = require("Core.Json.Serializable") })
