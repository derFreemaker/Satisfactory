local LoadedLoaderFiles = ({ ... })[1]
---@type object
local Object = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Object'][1]
---@type Utils.Table
local Table = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Table'][1]
local _MetatableModifier = LoadedLoaderFiles["/Github-Loading/Loader/Utils/Old/Class/Metatable"]
---@type Utils.Class.Modifier.Metatable, table
local MetatableModifier, SearchValueInBase = _MetatableModifier[1], _MetatableModifier[2]
---@type Utils.Class.Construction
local Construction = LoadedLoaderFiles["/Github-Loading/Loader/Utils/Old/Class/Construction"][1]

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
    local classMetatable = getmetatable(class) or {}

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
