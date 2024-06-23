---@class TDS.Entities.Request.Create
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
---@field ItemName string
---@overload fun(id: Core.UUID, state: TDS.Request.State, trainId: Core.UUID | nil, itemName: string) : TDS.Entities.Request
local Request = {}

---@private
---@param id Core.UUID
---@param state TDS.Request.State
---@param trainId Core.UUID | nil
---@param itemName string
function Request:__init(id, state, trainId, itemName)
    self.Id = id
    self.State = state
    self.TrainId = trainId
    self.ItemName = itemName
end

function Request:Serialize()
    return self.Id, self.State, self.TrainId, self.ItemName
end

return class("TDS.Request", Request,
    { Inherit = require("Core.Json.Serializable") })
