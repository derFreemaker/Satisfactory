local ClassManipulation = require("Ficsit-Networks_Sim.Utils.ClassManipulation")
local Object = require("Ficsit-Networks_Sim.Component.Entities.Object")

---@class Ficsit_Networks_Sim.Component.Entities.Color
---@field r number Red
---@field g number Green
---@field b number Blue
---@field a number Alpha
local Color = ClassManipulation.CreateClass("Color")
return Color