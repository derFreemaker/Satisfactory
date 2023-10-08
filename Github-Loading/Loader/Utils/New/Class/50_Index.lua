local LoadedLoaderFiles = ({ ... })[1]
---@type Utils.new.Class.MembersHandler
local MembersHandler = LoadedLoaderFiles['/Github-Loading/Loader/Utils/New/Class/MembersHandler'][1]
---@type Utils.new.Class.TypeHandler
local TypeHandler = LoadedLoaderFiles['/Github-Loading/Loader/Utils/New/Class/TypeHandler'][1]
---@type Utils.new.Class.ConstructionHandler
local ConstructionHandler = LoadedLoaderFiles['/Github-Loading/Loader/Utils/New/Class/ConstructionHandler'][1]

---@class Utils.new.Class
local Class = {}

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

return Class
