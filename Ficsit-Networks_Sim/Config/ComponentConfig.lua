local Tools = require("Ficsit-Networks_Sim.Utils.Tools")
local Component = require("Ficsit-Networks_Sim.Component.Component")

---@class Ficsit_Networks_Sim.Component.Config
---@field Components Array<Ficsit_Networks_Sim.Component.Component>
---@field EntitiesPath string
local ComponentConfig = {}
ComponentConfig.__index = ComponentConfig

---@param simLibPath Ficsit_Networks_Sim.Filesystem.Path
---@return Ficsit_Networks_Sim.Component.Config
function ComponentConfig.new(simLibPath)
    return setmetatable({
        Components = {},
        EntitiesPath = simLibPath
            :Extend("Component")
            :Extend("Entities")
            :GetPath()
    }, ComponentConfig)
end

---@param id string
---@param cType Ficsit_Networks_Sim.Component.Types
---@param data table | nil
---@param nickname string | nil
---@return Ficsit_Networks_Sim.Component.Config
function ComponentConfig:AddComponent(id, cType, data, nickname)
    Tools.CheckParameterType(id, "string", 1)
    Tools.CheckParameterType(cType, "string", 2)
    Tools.CheckParameterType(data, { "table", "nil" }, 3)
    Tools.CheckParameterType(nickname, { "string", "nil" }, 4)
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

return ComponentConfig