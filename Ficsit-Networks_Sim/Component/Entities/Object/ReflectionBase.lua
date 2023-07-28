local ClassManipulation = require("Ficsit-Networks_Sim.Utils.ClassManipulation")
local Object = require("Ficsit-Networks_Sim.Component.Entities.Object")

---@class Ficsit_Networks_Sim.Component.Entities.ReflectionBase : Ficsit_Networks_Sim.Component.Entities.Object
---@field name string
---@field displayName string
---@field description string
local ReflectionBase = ClassManipulation.CreateSubclass(Object, "ReflectionBase")
ReflectionBase.__index = ReflectionBase

return ReflectionBase