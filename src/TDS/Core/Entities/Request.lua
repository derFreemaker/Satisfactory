---@class TDS.Request.Create
---@field StationId Core.UUID
---@field Item string

---@class TDS.Request : object, Core.Json.Serializable
---@field Id Core.UUID
---@field StationId Core.UUID
---@field ItemName string
---@overload fun(id: Core.UUID, stationId: Core.UUID, itemName: string) : TDS.Request
local Request = {}

---@private
---@param id Core.UUID
---@param stationId Core.UUID
---@param itemName string
function Request:__init(id, stationId, itemName)
    self.Id = id
    self.StationId = stationId
    self.ItemName = itemName
end

function Request:Serialize()
    return self.Id, self.StationId, self.ItemName
end

return class("TDS.Request", Request,
    { Inherit = require("Core.Json.Serializable") })
