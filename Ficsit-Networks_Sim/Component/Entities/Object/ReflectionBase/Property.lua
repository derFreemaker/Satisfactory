local ClassManipulation = require("Ficsit-Networks_Sim.Utils.ClassManipulation")
local ReflectionBase = require("Ficsit-Networks_Sim.Component.Entities.Object.ReflectionBase")

---@class Ficsit_Networks_Sim.Component.Entities.Property : Ficsit_Networks_Sim.Component.Entities.ReflectionBase
---@field dataType Ficsit_Networks_Sim.Component.DataType
---@field flags integer //TODO: flags
local Property = ClassManipulation.CreateSubclass(ReflectionBase, "Property")
Property.__index = Property

return Property