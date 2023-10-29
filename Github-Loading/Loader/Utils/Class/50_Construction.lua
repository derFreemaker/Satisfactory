local LoadedLoaderFiles = ({ ... })[1]
---@type Utils.Class.Configs
local Configs = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Class/Config'][1]
---@type Utils.Table
local Table = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Table'][1]
---@type Utils.Class.MetatableHandler
local MetatableHandler = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Class/Metatable'][1]
---@type Utils.Class.InstanceHandler
local InstanceHandler = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Class/Instance'][1]

---@class Utils.Class.Template

---@class Utils.Class.ConstructionHandler
local ConstructionHandler = {}

---@param obj object
---@return Utils.Class.Instance instance
local function construct(obj, ...)
    ---@type Utils.Class.Metatable
    local metatable = getmetatable(obj)
    local typeInfo = metatable.Type

    local classInstance, classMetatable = {}, {}
    ---@cast classInstance Utils.Class.Instance
    ---@cast classMetatable Utils.Class.Metatable

    MetatableHandler.CreateMetatable(typeInfo, classMetatable)
    ConstructionHandler.ConstructClass(typeInfo, classInstance, classMetatable, ...)

    InstanceHandler.Add(typeInfo, classInstance)

    return classInstance
end

---@param typeInfo Utils.Class.Type
---@param data table
function ConstructionHandler.ConstructTemplate(typeInfo, data)
    Table.Clear(data)
    InstanceHandler.Initialize(typeInfo)

    local metatable = MetatableHandler.CreateTemplateMetatable(typeInfo)
    metatable.__call = construct

    data = setmetatable(data, metatable)
    typeInfo.Template = data
end

---@param typeInfo Utils.Class.Type
---@param class table
---@param classMetatable Utils.Class.Metatable
---@param ... any
function ConstructionHandler.ConstructClass(typeInfo, class, classMetatable, ...)
    ---@type function
    local baseFunc = nil

    local function constructMembers()
        for key, value in pairs(typeInfo.MetaMethods) do
            if not Table.ContainsKey(Configs.IndirectMetaMethods, key) then
                rawset(classMetatable, key, value)
            end
        end

        for key, value in pairs(typeInfo.Members) do
            if type(value) == "table" then
                rawset(class, key, Table.Copy(value))
                goto continue
            end

            rawset(class, key, value)
            ::continue::
        end

        setmetatable(class, classMetatable)
    end

    if typeInfo.Base then
        if typeInfo.Base.HasConstructor then
            function baseFunc(...)
                ConstructionHandler.ConstructClass(typeInfo.Base, class, classMetatable, ...)
                constructMembers()
            end
        else
            ConstructionHandler.ConstructClass(typeInfo.Base, class, classMetatable)
            constructMembers()
        end
    else
        constructMembers()
    end

    if typeInfo.HasConstructor then
        if baseFunc then
            typeInfo.MetaMethods.__init(class, baseFunc, ...)
        else
            typeInfo.MetaMethods.__init(class, ...)
        end
    end
end

---@param typeInfo Utils.Class.Type
---@param class table
local function invokeDeconstructor(typeInfo, class)
    if typeInfo.HasConstructor then
        typeInfo.MetaMethods.__gc(class)
        invokeDeconstructor(typeInfo.Base, class)
    end
end

---@param typeInfo Utils.Class.Type
---@param class table
---@param metatable Utils.Class.Metatable
function ConstructionHandler.Deconstruct(typeInfo, class, metatable)
    InstanceHandler.Remove(typeInfo, class)
    invokeDeconstructor(typeInfo, class)

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

return ConstructionHandler
