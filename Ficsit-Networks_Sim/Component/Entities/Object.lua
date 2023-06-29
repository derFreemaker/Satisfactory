---@class Ficsit_Networks_Sim.Component.Entities.Object
---@field private type string
---@field private hash integer
---@field internalName string
---@field internalPath string
local Object = {
    type = "Object"
}
Object.__index = Object

---@return Ficsit_Networks_Sim.Component.Entities.Object
function Object.new()
    return setmetatable({}, Object)
end

---@param data table
---@return Ficsit_Networks_Sim.Component.Entities.Object
function Object.newWithData(data)
    return setmetatable(data, Object)
end

---@return integer
function Object:GetHash()
    return self.hash
end

---@return string
function Object:GetType()
    return self.type
end

return Object