---@type function
local useBase = table.pack(...)[1]
local Object = require("Ficsit-Networks_Sim.Component.Entities.Object")

---@class Ficsit_Networks_Sim.Component.Entities.ItemType : Ficsit_Networks_Sim.Component.Entities.Object
---@field form integer
---@field energy number
---@field radioactiveDecay number
---@field name string
---@field max integer
---@field canBeDiscarded boolean
---@field category Ficsit_Networks_Sim.Component.Entities.ItemCategory
---@field fluidColor Ficsit_Networks_Sim.Component.Entities.Color
local ItemType = useBase({
    type = "ItemType"
}, Object.new())
ItemType.__index = ItemType

---@return Ficsit_Networks_Sim.Component.Entities.ItemType
function ItemType.new()
    return setmetatable({}, ItemType)
end

---@param data table
---@return Ficsit_Networks_Sim.Component.Entities.ItemType
function ItemType.newWithData(data)
    return setmetatable(data, ItemType)
end

return ItemType