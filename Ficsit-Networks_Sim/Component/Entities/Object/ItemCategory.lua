local ClassManipulation = require("Ficsit-Networks_Sim.Utils.ClassManipulation")
local Object = require("Ficsit-Networks_Sim.Component.Entities.Object")

---@class Ficsit_Networks_Sim.Component.Entities.ItemCategory : Ficsit_Networks_Sim.Component.Entities.Object
---@field name string
local ItemCategory = ClassManipulation.CreateSubclass(Object, "ItemCategory")
ItemCategory.__index = ItemCategory

return ItemCategory