---@class Ficsit_Networks_Sim.Component.Component
---@field Id string
---@field Nickname string | nil
---@field Type Ficsit_Networks_Sim.Component.Types
---@field Data table | nil
---@field private instance Ficsit_Networks_Sim.Component.Entities.Object
local Component = {}
Component.__index = Component

---@param id string
---@param type Ficsit_Networks_Sim.Component.Types
---@param nickname string | nil
---@param data table | nil
---@return Ficsit_Networks_Sim.Component.Component
function Component.new(id, type, nickname, data)
    return setmetatable({
        Id = id,
        Nickname = nickname,
        Type = type,
        Data = data
    }, Component)
end

---@param componentManager Ficsit_Networks_Sim.Component.ComponentManager
---@return Ficsit_Networks_Sim.Component.Entities.Object
function Component:Build(componentManager)
    if not self.instance then
        self.instance = componentManager:GetComponentClass(self.Type)
    end
    return self.instance(self.Data)
end

return Component