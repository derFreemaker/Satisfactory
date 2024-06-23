local CustomReference = require("Core.References.CustomReference")

---@class TDS.Server.Entities.Train.Create
---@field State TDS.Server.Entities.Train.State

---@alias TDS.Server.Entities.Train.State
---|"None"
---|"Traveling"
---|"Idle"
---|"Working"

---@class TDS.Server.Entities.Train : object, Core.Json.Serializable
---@field Id Core.UUID
---@field State TDS.Server.Entities.Train.State
---@field m_ref Core.Ref<Satis.Train>
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

---@return Core.Ref<Satis.Train>
function Train:GetRef()
    if self.m_ref then
        return self.m_ref
    end

    self.m_ref = CustomReference(trainRefFetch(self.Id:ToString()))
    return self.m_ref
end

---@return boolean
function Train:IsValid()
    --//TODO: find better solution maybe
    return self:GetRef():IsValid()
end

function Train:Serialize()
    return self.Id, self.State
end

return class("TDS.Entities.Train", Train,
    { Inherit = require("Core.Json.Serializable") })
