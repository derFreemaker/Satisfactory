local LoadedLoaderFiles = ({ ... })[1]
---@type Utils.String
local String = LoadedLoaderFiles['/Github-Loading/Loader/Utils/String'][1]
---@type Utils.Table
local Table = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Table'][1]

---@class Utils.Class.Metatable : Utils.Class.MetaMethods
---@field Type Utils.Class.Type

---@type Dictionary<string, boolean>
local metaMethods = {
    __gc = true,
    __call = true,
    __tostring = true,
    __add = true,
    __sub = true,
    __mul = true,
    __div = true,
    __mod = true,
    __pow = true,
    __unm = true,
    __idiv = true,
    __band = true,
    __bor = true,
    __bxor = true,
    __bnot = true,
    __shl = true,
    __shr = true,
    __concat = true,
    __len = true,
    __eq = true,
    __lt = true,
    __le = true,
}

---@type Dictionary<string, boolean>
local overrideMetaMethods = {
    __pairs = true,
    __ipairs = true,
}

local function blockedNewIndex()
    error("cannot assign values to class type info", 2)
end

---@param t table
---@param key any
---@param value any
local function letOnlyStaticNamesThrough_NewIndex(t, key, value)
    if type(key) ~= "string" then
        error("only static values can be set", 2)
    end

    local splittedKey = String.Split(key, "__")
    if not Table.Contains(splittedKey, "Static") then
        error("only static values can be set", 2)
    end

    rawset(t, key, value)
end

---@param t table
---@param func function
local function writeToNewIndex(t, func)
    local metatable = getmetatable(t) or {}
    metatable.__newindex = func
    setmetatable(t, metatable)
end

---@param typeInfo Utils.Class.Type
---@param key string
local function searchInStatic(typeInfo, key)
    local value = typeInfo.Static[key]

    if value == nil then
        if typeInfo.Name == "object" then
            return nil
        end

        return searchInStatic(typeInfo.Base, key)
    end

    return value
end

---@param typeInfo Utils.Class.Type
---@param key string
---@param value any
---@return boolean wasFound
local function assignInStatic(typeInfo, key, value)
    if typeInfo.Static[key] ~= nil then
        typeInfo.Static[key] = value
        return true
    end

    if typeInfo.Name == "object" then
        return false
    end

    return assignInStatic(typeInfo.Base, key, value)
end

---@class Utils.Class.MetatableHandler
local MetatableHandler = {}

---@param typeInfo Utils.Class.Type
---@return Utils.Class.Metatable templateMetatable
function MetatableHandler.CreateTemplateMetatable(typeInfo)
    ---@type Utils.Class.Metatable
    local metatable = { Type = typeInfo }

    ---@param obj object
    ---@param key any
    ---@return any value
    local function index(obj, key)
        if type(key) ~= "string" then
            error("can only use static members in template")
            return {}
        end

        local splittedKey = String.Split(key, "__")
        if Table.Contains(splittedKey, "Static") then
            return searchInStatic(typeInfo, key)
        end

        error("can only use static members in template")
    end
    metatable.__index = index

    ---@param obj object
    ---@param key any
    ---@param value any
    local function newindex(obj, key, value)
        if type(key) ~= "string" then
            error("can only use static members in template")
            return
        end

        local splittedKey = String.Split(key, "__")
        if Table.Contains(splittedKey, "Static") then
            if not assignInStatic(typeInfo, key, value) then
                typeInfo.Static[key] = value
            end
            return
        end

        error("can only use static members in template")
    end
    metatable.__newindex = newindex

    for key, _ in pairs(overrideMetaMethods) do
        if not Table.ContainsKey(metatable, key) then
            local function blockMetaMethod()
                error("cannot use meta method: " .. key .. " in class: " .. typeInfo.Name)
            end
            ---@diagnostic disable-next-line: assign-type-mismatch
            metatable[key] = blockMetaMethod
        end
    end

    return metatable
end

---@param typeInfo Utils.Class.Type
---@param metatable Utils.Class.Metatable
function MetatableHandler.CreateMetatable(typeInfo, metatable)
    metatable.Type = typeInfo

    ---@param obj Utils.Class
    ---@param key any
    ---@return any value
    local function index(obj, key)
        if typeInfo.HasIndex and type(key) == "number" then
            return typeInfo.MetaMethods.__index(obj, key)
        end

        if type(key) == "string" then
            local splittedKey = String.Split(key, "__")
            if Table.Contains(splittedKey, "Static") then
                return searchInStatic(typeInfo, key)
            end
        end

        return rawget(obj, key)
    end
    metatable.__index = index

    ---@param obj object
    ---@param key any
    ---@param value any
    local function newindex(obj, key, value)
        if typeInfo.HasIndex and type(key) == "number" then
            typeInfo.MetaMethods.__newindex(obj, key, value)
        end

        if type(key) == "string" then
            local splittedKey = String.Split(key, "__")
            if Table.Contains(splittedKey, "Static") then
                if not assignInStatic(typeInfo, key, value) then
                    typeInfo.Static[key] = value
                end
                return
            end
        end

        return rawset(obj, key, value)
    end
    metatable.__newindex = newindex

    for key, _ in pairs(overrideMetaMethods) do
        if not Table.ContainsKey(typeInfo.MetaMethods, key) then
            local function blockMetaMethod()
                error("cannot use meta method: " .. key .. " in class: " .. typeInfo.Name)
            end
            metatable[key] = blockMetaMethod
        end
    end
end

---@param typeInfo Utils.Class.Type
function MetatableHandler.LockMetatables(typeInfo)
    writeToNewIndex(typeInfo, blockedNewIndex)
    writeToNewIndex(typeInfo.Members, blockedNewIndex)
    writeToNewIndex(typeInfo.MetaMethods, blockedNewIndex)
    writeToNewIndex(typeInfo.Static, letOnlyStaticNamesThrough_NewIndex)
end

return MetatableHandler, metaMethods, overrideMetaMethods, blockedNewIndex
