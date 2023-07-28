local ClassManipulation = require("Ficsit-Networks_Sim.Utils.ClassManipulation")
local Object = require("Ficsit-Networks_Sim.Component.Entities.Object")

---@class Ficsit_Networks_Sim.Component.Entities.Actor : Ficsit_Networks_Sim.Component.Entities.Object
local Actor = ClassManipulation.CreateSubclass(Object, "Actor")
Actor.__index = Actor

return Actor