local LoadedLoaderFiles = table.pack(...)[1]
---@type object
local Object = LoadedLoaderFiles["/Github-Loading/Loader/Utils/Object"][1]
---@type Utils.String
local String = LoadedLoaderFiles["/Github-Loading/Loader/Uitls/String"][1]
---@type Utils.Table
local Table = LoadedLoaderFiles["/Github-Loading/Loader/Utils/Table"][1]

---@class Utils.Class
local Class = {}
Class.SearchValueInBase = {}


local metatableMethods = {
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
    __index = true,
    __newindex = true,
    __pairs = true,
    __ipairs = true,
    __tostring = true,
    __gc = true,
    __call = true
}

---@param class table
---@param metatable Utils.Class.Metatable
---@param key string
---@param value any
local function hasStringKey(class, metatable, key, value)
    local splittedKey = String.Split(key, "__")
    if not Table.Contains(splittedKey, "Static") then
        if type(value) == "function" then
            metatable.Functions[key] = value
            class[key] = nil
        else
            metatable.Properties[key] = value
            class[key] = nil
        end
    end
end

---@param class table
---@param metatable Utils.Class.Metatable
local function HideMembers(class, metatable)
    ---@diagnostic disable-next-line
    metatable.MetaMethods = {}
    metatable.Functions = {}
    metatable.Properties = {}
    for key, value in pairs(class) do
        if type(key) == "string" then
            hasStringKey(class, metatable, key, value)
        else
            if type(value) == "function" then
                metatable.Functions[key] = value
                class[key] = nil
            else
                metatable.Properties[key] = value
                class[key] = nil
            end
        end
    end
end

---@param class table
---@param metatable Utils.Class.Metatable
local function ShowMembers(class, metatable)
    for key, value in pairs(metatable.MetaMethods) do
        metatable[key] = value
    end
    for key, value in pairs(metatable.Functions) do
        rawset(class, key, value)
    end
    for key, value in pairs(metatable.Properties) do
        rawset(class, key, value)
    end
    metatable.MetaMethods = nil
    metatable.Functions = nil
    metatable.Properties = nil
    setmetatable(class, metatable)
end


local overrideMetaMethods = {
    "__pairs",
    "__ipairs",
}
---@param metatable Utils.Class.Metatable
local function OverrideMetaMethods(metatable)
    for _, metaMethod in pairs(overrideMetaMethods) do
        if not metatable.MetaMethods[metaMethod] then
            local function throwError()
                error("can not use: '" .. metaMethod .. "' on class type: '" .. metatable.Type .. "'", 2)
            end
            metatable.MetaMethods[metaMethod] = throwError
        end
    end
end


---@param class object
---@param key any
local function index(class, key)
    ---@type Utils.Class.Metatable
    local classMetatable = getmetatable(class)
    if classMetatable.ConstructorState == 1 then
        error("cannot get values if class: " .. classMetatable.Type .. " was not constructed", 2)
    end
    local value
    if classMetatable.HasIndex then
        value = classMetatable.Index(class, key)
    else
        value = rawget(class, key) or Class.SearchValueInBase
    end
    if value ~= Class.SearchValueInBase then
        return value
    end
    local baseClass = classMetatable.Base
    value = baseClass[key]
    return value
end

---@param baseClass table
---@param metatable Utils.Class.Metatable
local function AddBaseClass(baseClass, metatable)
    metatable.Base = baseClass
    ---@type Utils.Class.Metatable
    local baseClassMetatable = getmetatable(baseClass)
    baseClassMetatable.IsBaseClass = true
    metatable.HasBaseClass = true

    local __index = metatable.MetaMethods.__index
    if type(__index) == "function" then
        metatable.Index = __index
        metatable.MetaMethods.__index = nil
        metatable.HasIndex = true
    else
        metatable.HasIndex = false
    end

    metatable.__index = index
end


---@param class object
---@param key any
---@param value any
local function newIndex(class, key, value)
    ---@type Utils.Class.Metatable
    local classMetatable = getmetatable(class)
    if classMetatable.ConstructorState == 1 then
        error("cannot assign values if class: " .. classMetatable.Type .. " was not constructed", 2)
    end
    if classMetatable.HasNewIndex then
        classMetatable.__newindex = classMetatable.NewIndex
        classMetatable.NewIndex(class, key, value)
        classMetatable.NewIndex = nil
        return
    end
    rawset(class, key, value)
end

---@param metatable Utils.Class.Metatable
local function AddNewIndex(metatable)
    local __newindex = metatable.MetaMethods.__newindex
    if type(__newindex) == "function" then
        metatable.NewIndex = __newindex
        metatable.MetaMethods.__newindex = nil
        metatable.HasNewIndex = true
    else
        metatable.HasNewIndex = false
    end

    metatable.__newindex = newIndex
end


---@generic TBaseClass
---@param class TBaseClass
---@return TBaseClass
local function CopyIfNotBaseClass(class)
    ---@type Utils.Class.Metatable
    local classMetatable = getmetatable(class)
    if classMetatable.IsBaseClass then
        return class
    end
    return Utils.Table.Copy(class)
end

---@param metatable Utils.Class.Metatable
local function AddConstructor(metatable)
    ---@type fun(self: object, ...: any, base: object | nil)
    local constructor = metatable.MetaMethods.__call

    ---@param class object
    ---@param ... any
    local function construct(class, ...) ---@diagnostic disable-line: redefined-local
        class = CopyIfNotBaseClass(class)
        ---@type Utils.Class.Metatable
        local classMetatable = getmetatable(class)
        classMetatable.__call = nil
        classMetatable.ConstructorState = 2
        ShowMembers(class, classMetatable)

        if classMetatable.HasBaseClass then
            local baseClass = classMetatable.Base
            ---@type Utils.Class.Metatable
            local baseClassMetatable = getmetatable(baseClass)

            if classMetatable.HasConstructor and baseClassMetatable.HasConstructor then
                if #{ ... } == 0 then
                    constructor(class, baseClass)
                else
                    constructor(class, ..., baseClass)
                end
                if baseClassMetatable.ConstructorState ~= 3 then
                    error(
                        "base class from class: '" .. classMetatable.Type .. "' did not get constructed or didn't finish",
                        2)
                end
            elseif classMetatable.HasConstructor and not baseClassMetatable.HasConstructor then
                baseClass = baseClass()
                constructor(class, ...)
            else
                baseClass = baseClass()
            end
        elseif classMetatable.HasConstructor then
            constructor(class, ...)
        end

        classMetatable.ConstructorState = 3
        return class
    end

    metatable.__call = construct
    metatable.ConstructorState = 1
    if type(constructor) == "function" then
        metatable.HasConstructor = true
        metatable.MetaMethods.__call = nil
        return
    end

    metatable.HasConstructor = false
    if metatable.HasBaseClass then
        ---@type Utils.Class.Metatable
        local baseClassMetatable = getmetatable(metatable.Base)
        if baseClassMetatable.HasConstructor then
            error("create class: '" .. metatable.Type .. "' with no constructor when the base class has a constructor", 2)
        end
    end
end


---@param metatable Utils.Class.Metatable
local function AddDeconstructor(metatable)
    ---@type fun(class: object)?
    local deconstructor = metatable.MetaMethods.__gc

    ---@param class object
    local function deconstruct(class)
        ---@cast deconstructor fun(class: object)

        ---@type Utils.Class.Metatable
        local classMetatable = getmetatable(class)
        classMetatable.__gc = nil

        deconstructor(class)
    end

    if type(deconstructor) == "function" then
        metatable.MetaMethods.__gc = deconstruct
        metatable.HasDeconstructor = true
        return
    end
    metatable.HasDeconstructor = false
end


---@generic TClass
---@generic TBaseClass
---@param class TClass
---@param classType string
---@param baseClass TBaseClass
---@return TClass
function Class.CreateSubClass(class, classType, baseClass)
    baseClass = Utils.Table.Copy(baseClass)
    if not Class.HasClassOfType(baseClass, "object") then
        error("base class argument is not a class", 2)
    end
    ---@type Utils.Class.Metatable
    local classMetatable = getmetatable(class)
    if classMetatable == nil then
        ---@diagnostic disable-next-line
        classMetatable = {}
        setmetatable(class, classMetatable)
    end
    classMetatable.Type = classType
    classMetatable.IsBaseClass = false
    ---@cast class table
    HideMembers(class, classMetatable)
    OverrideMetaMethods(classMetatable)
    AddNewIndex(classMetatable)
    AddBaseClass(baseClass, classMetatable)
    AddDeconstructor(classMetatable)
    AddConstructor(classMetatable)
    setmetatable(class, classMetatable)
    return class
end


---@generic TClass
---@param class TClass
---@param classType string
---@return TClass
function Class.CreateClass(class, classType)
    return Class.CreateSubClass(class, classType, Object)
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
    if metatable.HasBaseClass then
        return Class.HasClassOfType(metatable.Base, classType)
    end
    return false
end


---@param class object
---@return object? base
function Class.GetBaseClass(class)
    ---@type Utils.Class.Metatable
    local classMetatable = getmetatable(class)
    if classMetatable.HasBaseClass then
        return classMetatable.Base
    end
    return nil
end


return Class