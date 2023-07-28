local ClassManipulation = require("Ficsit-Networks_Sim.Utils.ClassManipulation")
local Property = require("Ficsit-Networks_Sim.Component.Entities.Object.ReflectionBase.Property")

---@class Ficsit_Networks_Sim.Component.Entities.ClassProperty : Ficsit_Networks_Sim.Component.Entities.Property
local ClassProperty = ClassManipulation.CreateSubclass(Property, "ClassProperty")
ClassProperty.__index = ClassProperty

function ClassProperty:getSubclass()
    return getmetatable(self).__base.typeClas
end

return ClassProperty