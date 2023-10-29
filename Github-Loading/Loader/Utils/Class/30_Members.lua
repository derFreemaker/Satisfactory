local LoadedLoaderFiles = ({ ... })[1]
---@type Utils.Class.Configs
local Configs = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Class/Config'][1]
---@type Utils.String
local String = LoadedLoaderFiles['/Github-Loading/Loader/Utils/String'][1]
---@type Utils.Table
local Table = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Table'][1]
---@type Utils.Class.InstanceHandler
local InstanceHandler = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Class/Instance'][1]

---@class Utils.Class.MembersHandler
local MembersHandler = {}

---@param typeInfo Utils.Class.Type
function MembersHandler.UpdateState(typeInfo)
    typeInfo.HasConstructor = typeInfo.MetaMethods.__init ~= nil
    typeInfo.HasDeconstructor = typeInfo.MetaMethods.__gc ~= nil
    typeInfo.HasIndex = typeInfo.MetaMethods.__index ~= nil
    typeInfo.HasNewIndex = typeInfo.MetaMethods.__newindex ~= nil
end

-------------------------------------------------------------------------------
-- Sort
-------------------------------------------------------------------------------

---@param typeInfo Utils.Class.Type
---@param name string
---@param func function
local function isNormalFunction(typeInfo, name, func)
    if Table.ContainsKey(Configs.AllMetaMethods, name) then
        typeInfo.MetaMethods[name] = func
        return
    end

    typeInfo.Members[name] = func
end

---@param typeInfo Utils.Class.Type
---@param name string
---@param value any
local function isNormalMember(typeInfo, name, value)
    if type(value) == 'function' then
        isNormalFunction(typeInfo, name, value)
        return
    end

    typeInfo.Members[name] = value
end

---@param typeInfo Utils.Class.Type
---@param name string
---@param value any
local function isStaticMember(typeInfo, name, value)
    typeInfo.Static[name] = value
end

---@param typeInfo Utils.Class.Type
---@param key any
---@param value any
local function sortMember(typeInfo, key, value)
    if type(key) == 'string' then
        local splittedKey = String.Split(key, '__')
        if Table.Contains(splittedKey, 'Static') then
            isStaticMember(typeInfo, key, value)
            return
        end

        isNormalMember(typeInfo, key, value)
        return
    end

    typeInfo.Members[key] = value
end

---@param data table
---@param typeInfo Utils.Class.Type
function MembersHandler.SortMembers(data, typeInfo)
    typeInfo.Static = {}
    typeInfo.MetaMethods = {}
    typeInfo.Members = {}

    for key, value in pairs(data) do
        sortMember(typeInfo, key, value)
    end

    MembersHandler.UpdateState(typeInfo)
end

-------------------------------------------------------------------------------
-- Extend
-------------------------------------------------------------------------------

---@param typeInfo Utils.Class.Type
---@param name string
---@param func function
local function UpdateMethods(typeInfo, name, func)
    if Table.ContainsKey(typeInfo.Members, name) then
        error("trying to extend already existing meta method: " .. name)
    end

    InstanceHandler.UpdateMetaMethod(typeInfo, name, func)
end

---@param typeInfo Utils.Class.Type
---@param key any
---@param value any
local function UpdateMember(typeInfo, key, value)
    if Table.ContainsKey(typeInfo.Members, key) then
        error("trying to extend already existing member: " .. tostring(key))
    end

    InstanceHandler.UpdateMember(typeInfo, key, value)
end

---@param typeInfo Utils.Class.Type
---@param name string
---@param value any
local function extendIsStaticMember(typeInfo, name, value)
    if Table.ContainsKey(typeInfo.Static, name) then
        error("trying to extend already existing static member: " .. name)
    end

    typeInfo.Static[name] = value
end

---@param typeInfo Utils.Class.Type
---@param name string
---@param func function
local function extendIsNormalFunction(typeInfo, name, func)
    if Table.ContainsKey(Configs.AllMetaMethods, name) then
        UpdateMethods(typeInfo, name, func)
    end

    UpdateMember(typeInfo, name, func)
end

---@param typeInfo Utils.Class.Type
---@param name string
---@param value any
local function extendIsNormalMember(typeInfo, name, value)
    if type(value) == 'function' then
        extendIsNormalFunction(typeInfo, name, value)
        return
    end

    UpdateMember(typeInfo, name, value)
end

---@param typeInfo Utils.Class.Type
---@param key any
---@param value any
local function extendMember(typeInfo, key, value)
    if type(key) == 'string' then
        local splittedKey = String.Split(key, '__')
        if Table.Contains(splittedKey, 'Static') then
            extendIsStaticMember(typeInfo, key, value)
            return
        end

        extendIsNormalMember(typeInfo, key, value)
        return
    end

    if not Table.ContainsKey(typeInfo.Members, key) then
        typeInfo.Members[key] = value
    end
end

---@param data table
---@param typeInfo Utils.Class.Type
function MembersHandler.ExtendMembers(data, typeInfo)
    for key, value in pairs(data) do
        extendMember(typeInfo, key, value)
    end

    MembersHandler.UpdateState(typeInfo)
end

return MembersHandler
