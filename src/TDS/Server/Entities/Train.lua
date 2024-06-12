---@enum TDS.Entities.Train.State
local Train_State = {
    None = 0,
    Traveling = 1,
    Idle = 2,
    Working = 3,
}

---@class TDS.Entities.Train : object, Core.Json.Serializable
---@field Id Core.UUID
---@field State TDS.Entities.Train.State
---@field IsFluid boolean
---@overload fun(id: Core.UUID, state: TDS.Entities.Train.State, isFluid: boolean) : TDS.Entities.Train
local Train = {}

---@param id Core.UUID
---@param state TDS.Entities.Train.State
---@param isFluid boolean
function Train:__init(id, state, isFluid)
    self.Id = id
    self.State = state
    self.IsFluid = isFluid
end

function Train:Serialize()
    return self.Id, self.State, self.IsFluid
end

return class("TDS.Entities.Train", Train,
    { Inherit = require("Core.Json.Serializable") })
