local ClassManipulation = require("Ficsit-Networks_Sim.Utils.ClassManipulation")
local Property = require("Ficsit-Networks_Sim.Component.Entities.Object.ReflectionBase.Property")

---@class Ficsit_Networks_Sim.Component.Entities.ArrayProperty : Ficsit_Networks_Sim.Component.Entities.Property
---@field private inner Ficsit_Networks_Sim.Component.Entities.Property
local ArrayProperty = ClassManipulation.CreateSubclass(Property, "ArrayProperty")
ArrayProperty.__index = ArrayProperty

---@return Ficsit_Networks_Sim.Component.Entities.Property
function ArrayProperty:getInner()
    return self.inner
end

return ArrayProperty