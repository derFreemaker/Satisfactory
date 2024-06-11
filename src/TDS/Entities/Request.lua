---@class TDS.Request.Create
---@field ItemId integer
---@field 

---@enum TDS.Request.State
local Request_State = {
    None = 0,
    Waiting = 1,
    Processing = 2,
}

---@class TDS.Request : object, TDS.Request.Create, Core.Json.ISerializable
---@field Id Core.UUID
---@field State TDS.Request.State
---@field TrainId Core.UUID | nil
---@field ItemId integer
---@overload fun(id: Core.UUID, state: TDS.Request.State, trainId: Core.UUID | nil, itemId: integer) : TDS.Request
local Request = {}

---@private
---@param id Core.UUID
---@param state TDS.Request.State
---@param trainId Core.UUID | nil
function Request:__init(id, state, trainId)
    self.Id = id
    self.State = state
    self.TrainId = trainId
end

function Request:Serialize()
    return self.Id, self.State, self.TrainId
end

return class("TDS.Request", Request,
    { Inherit = require("Core.Json.ISerializable") })
