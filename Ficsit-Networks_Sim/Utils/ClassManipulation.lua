---@class Ficsit_Networks_Sim.Utils.ClassManipulation
local ClassManipulation = {}

---@generic TTable
---@param class TTable
---@param base table
---@return TTable
function ClassManipulation.useBase(class, base)
    setmetatable(class, {
        __index = function(table, key)
            local metatable = getmetatable(table)
            local value = metatable.__base[key]
            table[key] = value
            return value
        end,
        __base = base
    })
    return class
end

return ClassManipulation