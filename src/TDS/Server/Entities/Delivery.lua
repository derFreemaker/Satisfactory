---@class TDS.Server.Delivery.Create
---@field ItemName string
---@field TrainId Core.UUID
---@field GetStationId Core.UUID
---@field RecieveStationIds Core.UUID[]

---@class TDS.Server.Delivery : object, Core.Json.Serializable
---@field Id Core.UUID
---@field ItemName string
---@field TrainId Core.UUID
---@field GetStationId Core.UUID
---@field RecieveStationIds Core.UUID[]
---@overload fun(id: Core.UUID, itemName: string, getStationId: Core.UUID, recieveStationIds: Core.UUID[]) : TDS.Server.Delivery
local Delivery = {}

---@private
---@param id Core.UUID
---@param itemName string
---@param trainId Core.UUID
---@param getStationId Core.UUID
---@param recieveStationIds Core.UUID[]
function Delivery:__init(id, itemName, trainId, getStationId, recieveStationIds)
    self.Id = id
    self.ItemName = itemName
    self.TrainId = trainId
    self.GetStationId = getStationId
    self.RecieveStationId = recieveStationIds
end

function Delivery:Serialize()
    return self.Id, self.ItemName, self.TrainId, self.GetStationId, self.RecieveStationId
end

return class("TDS.Server.Entities.Delivery", Delivery,
    { Inherit = require("Core.Json.Serializable") })
