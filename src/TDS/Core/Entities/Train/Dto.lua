---@class TDS.Entities.Train.Dto : object, Core.Json.ISerializable
---@field Id Core.UUID
---@field NumCargoWagons integer
---@field NumFluidWagons integer
---@overload fun(id: Core.UUID, numCargoWagons: integer, numFluidWagons: integer) : TDS.Entities.Train.Dto
local Dto = {}

---@private
---@param id Core.UUID
---@param numCargoWagons integer
---@param numFluidWagons integer
function Dto:__init(id, numCargoWagons, numFluidWagons)
    self.Id = id
    self.NumCargoWagons = numCargoWagons
    self.NumFluidWagons = numFluidWagons
end

---@return Core.UUID id, integer numCargoWagons, integer numFluidWagons
function Dto:Serialize()
    return self.Id, self.NumCargoWagons, self.NumFluidWagons
end

return class("TDS.Entities.Train.Dto", Dto,
    { Inherit = require("Core.Json.ISerializable") })
