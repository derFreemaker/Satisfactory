local ClassManipulation = require("Ficsit-Networks_Sim.Utils.ClassManipulation")
local Object = require("Ficsit-Networks_Sim.Component.Entities.Object")

---@class Ficsit_Networks_Sim.Component.Entities.ItemType : Ficsit_Networks_Sim.Component.Entities.Object
---@field form integer
---@field energy number
---@field radioactiveDecay number
---@field name string
---@field max integer
---@field canBeDiscarded boolean
---@field category Class<Ficsit_Networks_Sim.Component.Entities.ItemCategory>
---@field fluidColor Struct<Ficsit_Networks_Sim.Component.Entities.Color>
local ItemType = ClassManipulation.CreateSubclass(Object, "ItemType")
return ItemType