local ClassManipulation = require("Ficsit-Networks_Sim.Utils.ClassManipulation")

---@class Ficsit_Networks_Sim.Component.Entities.Object
---@field private type string
---@field private hash integer
---@field internalName string
---@field internalPath string
local Object = ClassManipulation.CreateClass("Object")

---@return integer
function Object:GetHash()
    return self.hash
end

---@return string
function Object:GetType()
    return self.type
end

return Object