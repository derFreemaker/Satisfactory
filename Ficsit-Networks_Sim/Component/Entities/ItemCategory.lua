---@type function
local useBase = table.pack(...)[1]
local Object = require("Ficsit-Networks_Sim.Component.Entities.Object")

---@class Ficsit_Networks_Sim.Component.Entities.ItemCategory : Ficsit_Networks_Sim.Component.Entities.Object
---@field name string
local ItemCategory = useBase({
    type = "ItemCategory"
}, Object.new())
ItemCategory.__index = ItemCategory

---@return Ficsit_Networks_Sim.Component.Entities.ItemCategory
function ItemCategory.new()
    return setmetatable({}, ItemCategory)
end

return ItemCategory