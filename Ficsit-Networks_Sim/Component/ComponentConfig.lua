local Component = require("Ficsit-Networks_Sim.Component.Component")

---@class Ficsit_Networks_Sim.Component.Config
---@field Components Array<Ficsit_Networks_Sim.Component.Component>
local Config = {}
Config.__index = Config

---@return Ficsit_Networks_Sim.Component.Config
function Config.new()
    return setmetatable({
        Components = {}
    }, Config)
end

---@param id string
---@param cType Ficsit_Networks_Sim.Component.Types
---@param data table | nil
---@param nickname string | nil
---@return Ficsit_Networks_Sim.Component.Config
function Config:AddComponent(id, cType, data, nickname)
    if data and type(data) ~= "table" then
        error("data needs to be an table", 2)
    end
    for _, component in ipairs(self.Components) do
        if component.Id == id then
            error("Unable to add component with same id: '" .. id .. "'", 2)
        end
    end
    table.insert(self.Components, Component.new(id, cType, nickname, data))
    return self
end

return Config