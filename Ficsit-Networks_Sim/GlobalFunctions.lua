local args = table.pack(...)
---@type Ficsit_Networks_Sim.Component.ComponentManager
local ComponentManager = args[1]
local Tools = require("Ficsit-Networks_Sim.Utils.Tools")

---@param classStr Ficsit_Networks_Sim.Component.Types
---@return Ficsit_Networks_Sim.Component.Entities.Object
function findClass(classStr)
    Tools.CheckParameterType(classStr, "string")
    local class, _ = ComponentManager:GetComponentClass(classStr)
    if not class then
        error("Unable to find class: '" .. classStr .. "'", 2)
    end
    return class
end
