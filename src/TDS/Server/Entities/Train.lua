local CustomReference = require("Core.References.CustomReference")

---@alias TDS.Server.Entities.Train.State
---|"None"
---|"Traveling"
---|"Idle"
---|"Working"

---@class TDS.Server.Entities.Train : object, Core.Json.Serializable
---@field Id Core.UUID
---@field State TDS.Server.Entities.Train.State
---@overload fun(id: Core.UUID, state: TDS.Server.Entities.Train.State) : TDS.Server.Entities.Train
local Train = {}

---@param id Core.UUID
---@param state TDS.Server.Entities.Train.State
function Train:__init(id, state)
    self.Id = id
    self.State = state
end

---@param uuidStr string
---@return fun() : Satis.Train | nil
local function trainRefFetch(uuidStr)
    return function()
        ---@type Satis.RailroadStation
        local connectedStation = component.proxy(Config.StationId)
        if not connectedStation then
            error("Config.StationId is invalid or was not found")
        end

        local trains = connectedStation:getTrackGraph():getTrains()
        for _, train in pairs(trains) do
            if train:getName() == uuidStr then
                return train
            end
        end
    end
end

---@return Core.Reference<Satis.Train>
function Train:GetRef()
    return CustomReference(trainRefFetch(self.Id:ToString()))
end

function Train:Serialize()
    return self.Id, self.State
end

return class("TDS.Entities.Train", Train,
    { Inherit = require("Core.Json.Serializable") })
