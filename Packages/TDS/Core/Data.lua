local Data={
["TDS.Core.Entities.Request"] = [==========[
---@class TDS.Entities.Request.Data
---@field Item string

---@enum TDS.Request.State
local Request_State = {
    None = 0,
    Waiting = 1,
    Processing = 2,
}

---@class TDS.Entities.Request : object, Core.Json.Serializable
---@field Id Core.UUID
---@field State TDS.Request.State
---@field TrainId Core.UUID | nil
---@field Data TDS.Entities.Request.Data
---@overload fun(id: Core.UUID, state: TDS.Request.State, trainId: Core.UUID | nil, data: TDS.Entities.Request.Data) : TDS.Entities.Request
local Request = {}

---@private
---@param id Core.UUID
---@param state TDS.Request.State
---@param trainId Core.UUID | nil
---@param data TDS.Entities.Request.Data
function Request:__init(id, state, trainId, data)
    self.Id = id
    self.State = state
    self.TrainId = trainId
    self.Data = data
end

function Request:Serialize()
    return self.Id, self.State, self.TrainId, self.Data
end

return class("TDS.Request", Request,
    { Inherit = require("Core.Json.Serializable") })

]==========],
}

return Data
