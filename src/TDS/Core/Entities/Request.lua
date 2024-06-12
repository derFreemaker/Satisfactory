---@class TDS.Request.Data
---@field Item string

---@enum TDS.Request.State
local Request_State = {
    None = 0,
    Waiting = 1,
    Processing = 2,
}

---@class TDS.Request : object, Core.Json.Serializable
---@field Id Core.UUID
---@field State TDS.Request.State
---@field TrainId Core.UUID | nil
---@field Data TDS.Request.Data
---@overload fun(id: Core.UUID, state: TDS.Request.State, trainId: Core.UUID | nil, data: TDS.Request.Data) : TDS.Request
local Request = {}

---@private
---@param id Core.UUID
---@param state TDS.Request.State
---@param trainId Core.UUID | nil
---@param data TDS.Request.Data
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
