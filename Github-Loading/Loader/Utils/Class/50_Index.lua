local LoadedLoaderFiles = ({ ... })[1]
---@type object
local Object = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Object'][1]
---@type Utils.Table
local Table = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Table'][1]
local _MetatableModifier = LoadedLoaderFiles["/Github-Loading/Loader/Utils/Class/Metatable"]
---@type Utils.Class.Modifier.Metatable
local MetatableModifier = _MetatableModifier[1]
---@type table
local SearchValueInBase = _MetatableModifier[2]
---@type Utils.Class.Construction
local Construction = LoadedLoaderFiles["/Github-Loading/Loader/Utils/Class/Construction"][1]

---@class Utils.Class
local Class = {}
Class.SearchValueInBase = SearchValueInBase

---@generic TClass
---@generic TBaseClass
---@param class TClass
---@param classType string
---@param baseClass TBaseClass?
---@return TClass
function Class.CreateClass(class, classType, baseClass)
    if baseClass == nil then
        baseClass = Object
    elseif not Class.HasClassOfType(baseClass, 'object') then
        error('base class argument is not a class', 2)
    end
    baseClass = Table.Copy(baseClass) -- //TODO: find new way of constructing class wich is faster and does not use Table.Copy

    ---@type Utils.Class.Metatable
    local classMetatable = getmetatable(class)
    if classMetatable == nil then
        ---@diagnostic disable-next-line
        classMetatable = {}
    end

    classMetatable.Type = classType
    classMetatable.ConstructionState = "constructing"

    MetatableModifier.Prepare(class, classMetatable)
    Construction.Prepare(classMetatable, baseClass)

    MetatableModifier.BlockMetaMethods(classMetatable)
    classMetatable.ConstructionState = "waiting"
    setmetatable(class, classMetatable)
    return class
end

---@param class object
---@param classType string
---@return boolean hasClassOfType
function Class.HasClassOfType(class, classType)
    ---@type Utils.Class.Metatable
    local metatable = getmetatable(class)
    if metatable.Type == classType then
        return true
    end
    if metatable.Type == "object" then
        return false
    end
    return Class.HasClassOfType(metatable.Base, classType)
end

Class.Deconstruct = Construction.Deconstruct

return Class
