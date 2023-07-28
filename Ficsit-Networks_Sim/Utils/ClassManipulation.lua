local Tools = require("Ficsit-Networks_Sim.Utils.Tools")
local Event = require("Ficsit-Networks_Sim.Utils.Event")

---@class CreatedClass
---@field __onDeconstruct Event
---@field GetType function
---@field new function

---@class Ficsit_Networks_Sim.Utils.ClassManipulation
local ClassManipulation = {}

---@generic TTable
---@param table TTable
---@param typeToSet Ficsit_Networks_Sim.Component.Types
function ClassManipulation.UseType(table, typeToSet)
    Tools.CheckParameterType(table, "table")
    table.type = typeToSet
    function table:GetType()
        return self.type
    end
end

---@generic TTable
---@param table TTable
function ClassManipulation.CreateConstructor(table)
    Tools.CheckParameterType(table, "table")
    function table:new(data)
        return setmetatable(data or {}, self)
    end

    local metatable = getmetatable(table) or {}
    function metatable:__call(...)
        return self:new(...)
    end

    table = setmetatable(table, metatable)
end

---@generic TTable
---@param table TTable
function ClassManipulation.CreateDeconstructor(table)
    Tools.CheckParameterType(table, "table")
    table.__onDeconstruct = Event.new()
    function table:__gc()
        self.__onDeconstruct:Trigger(self)
    end
end

---@generic TTable
---@param classType Ficsit_Networks_Sim.Component.Types | string
---@param data TTable | nil
---@return TTable
function ClassManipulation.CreateClass(classType, data)
    Tools.CheckParameterType(classType, "string", 1)
    Tools.CheckParameterType(data, { "table", "nil" }, 2)
    local class = data or {}
    function class.__index(table, key)
        local value = rawget(table, key)
        if value ~= nil then
            return value
        end
        return getmetatable(table)[key]
    end

    ClassManipulation.CreateConstructor(class)
    ClassManipulation.CreateDeconstructor(class)
    ClassManipulation.UseType(class, classType)
    return class
end

---@generic TTable
---@param class TTable | nil
---@param baseClass table
---@return TTable
function ClassManipulation.UseBase(class, baseClass)
    Tools.CheckParameterType(class, "table", 1)
    Tools.CheckParameterType(baseClass, "table", 2)
    class = class or {}
    class.__base = baseClass
    function class.__index(table, key)
        local metatable = getmetatable(table)
        local value = rawget(table, key)
        if not value then
            value = rawget(metatable, key)
        end
        if not value and metatable.__base then
            value = metatable.__base[key]
        end
        table[key] = value
        return value
    end
    local classMetatable = {
        __call = getmetatable(baseClass).__call
    }
    return setmetatable(class, classMetatable)
end

---@generic TTable
---@param baseClass table
---@param classType Ficsit_Networks_Sim.Component.Types | string
---@param table TTable | nil
---@return TTable
function ClassManipulation.CreateSubclass(baseClass, classType, table)
    table = table or {}
    table = ClassManipulation.CreateClass(classType, table)
    table = ClassManipulation.UseBase(table, baseClass)
    return table
end

---@param table CreatedClass | table
---@param baseType Ficsit_Networks_Sim.Component.Types
---@return boolean
function ClassManipulation.IsClassOfType(table, baseType)
    Tools.CheckParameterType(table, "table", 1)
    Tools.CheckParameterType(baseType, "string", 2)
    if table:GetType() == baseType then
        return true
    end
    local metatable = getmetatable(table)
    if metatable.__base and type(metatable.__base) == "table" then
        return ClassManipulation.IsClassOfType(metatable.__base, baseType)
    end
    return false
end

return ClassManipulation