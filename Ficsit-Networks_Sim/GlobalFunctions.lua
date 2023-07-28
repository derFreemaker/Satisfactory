local args = table.pack(...)
---@type Ficsit_Networks_Sim.Component.ComponentManager
local ComponentManager = args[1]
---@type string
local SimLibPath = args[2]:gsub("%-", "_")
local Tools = require("Ficsit-Networks_Sim.Utils.Tools")

---@nodiscard
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

---@nodiscard
---@param structType Ficsit_Networks_Sim.Component.StructTypes
---@return Ficsit_Networks_Sim.Component.Entities.Object
function findStruct(structType)
    Tools.CheckParameterType(structType, "string")
    return findClass(structType)
end

---@nodiscard
---@param itemType Ficsit_Networks_Sim.Component.ItemTypes
---@return Ficsit_Networks_Sim.Component.Entities.Object
function findItem(itemType)
    Tools.CheckParameterType(itemType, "string")
    return findClass(itemType)
end

local isolated = {
    package = package,
    os = os,
    collectgarbage = collectgarbage,
    io = io,
    arg = arg,
    require = require
}

for key, _ in pairs(isolated) do
    _G[key] = nil
end

_G = setmetatable(_G, {
    __index = function(table, key)
        if not isolated[key] then
            rawget(table, key)
        end
        local source = debug.getinfo(2, "S").source:gsub("@", ""):gsub("\\", "/"):gsub("%-", "_")
        if source:find("^" .. SimLibPath) then
            return isolated[key]
        end
        error("Global: '".. key .."' is isolated")
    end
})

-- source: C:/Coding/Lua/Satisfactory/Ficsit-Networks_Sim/Simulator.lua
-- SimLibPath: C:/Coding/Lua/Satisfactory/Ficsit-Networks_Sim