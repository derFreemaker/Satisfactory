local LoadedLoaderFiles = ({ ... })[1]
---@type Utils.Table
local Table = LoadedLoaderFiles["/Github-Loading/Loader/Utils/Table"][1]
---@type Utils.Class.MembersHandler
local MembersHandler = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Class/MembersHandler'][1]
---@type Utils.Class.TypeHandler
local TypeHandler = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Class/TypeHandler'][1]
---@type Utils.Class.ConstructionHandler
local ConstructionHandler = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Class/ConstructionHandler'][1]

---@class Utils.Class
local Class = {}

---@type any
Class.Placeholder = {}

---@generic TClass
---@param data TClass
---@param name string
---@param baseClass object?
---@return TClass
function Class.CreateClass(data, name, baseClass)
    local typeInfo = TypeHandler.CreateType(name, baseClass)

    MembersHandler.SortMembers(data, typeInfo)

    ConstructionHandler.ConstructTemplate(typeInfo, data)
    return data
end

---@generic TClass : object
---@param extensions TClass
---@param class TClass
---@return TClass
function Class.ExtendClass(extensions, class)
    ---@type Out<Utils.Class.Metatable>
    local metatable = {}
    if not Class.IsClass(class, metatable) then
        error("provided class is not an class: " .. tostring(class))
        return class
    else
        metatable = metatable.Return
    end
    local typeInfo = metatable.Type

    MembersHandler.ExtendMembers(extensions, typeInfo)

    return typeInfo.Template
end

---@generic TClass
---@param class TClass
function Class.Deconstruct(class)
    ---@type Utils.Class.Metatable
    local metatable = getmetatable(class)
    local typeInfo = metatable.Type

    if metatable.__gc then
        metatable.__gc(class)
    end

    Table.Clear(class)
    Table.Clear(metatable)

    local function blockedNewIndex()
        error("cannot assign values to deconstruct class: " .. typeInfo.Name, 2)
    end
    metatable.__newindex = blockedNewIndex

    local function blockedIndex()
        error("cannot get values from deconstruct class: " .. typeInfo.Name, 2)
    end
    metatable.__index = blockedIndex

    setmetatable(class, metatable)
end

---@param baseClassName string
---@param type Utils.Class.Type
---@return boolean hasBaseClass
function Class.HasBaseClass(baseClassName, type)
    local typeName = type.Name
    if typeName == baseClassName then
        return true
    end

    if typeName == "object" then
        return false
    end

    return Class.HasBaseClass(baseClassName, type.Base)
end

---@param obj table
---@param metatableOut Out<Utils.Class.Metatable>?
---@return boolean isClass
function Class.IsClass(obj, metatableOut)
    if type(obj) ~= "table" then
        return false
    end

    local metatable = getmetatable(obj)

    if not metatable then
        return false
    end

    if not metatable.Type then
        return false
    end

    if not metatable.Type.Name then
        return false
    end

    if metatableOut then
        metatableOut.Return = metatable
    end

    return true
end

return Class
