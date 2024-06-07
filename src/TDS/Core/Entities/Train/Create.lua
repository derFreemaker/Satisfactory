---@class TDS.Entities.Train.Create : object, Core.Json.ISerializable
---@field NumCargoWagons integer
---@field NumFluidWagons integer
---@overload fun(numCargoWagons: integer, numFluidWagons: integer) : TDS.Entities.Train.Create
local Create = {}

---@private
---@param numCargoWagons integer
---@param numFluidWagons integer
function Create:__init(numCargoWagons, numFluidWagons)
    self.NumCargoWagons = numCargoWagons
    self.NumFluidWagons = numFluidWagons
end

---@return integer numCargoWagons, integer numFluidWagons
function Create:Serialize()
    return self.NumCargoWagons, self.NumFluidWagons
end

return class("TDS.Entities.Train.Create", Create,
    { Inherit = require("Core.Json.ISerializable") })