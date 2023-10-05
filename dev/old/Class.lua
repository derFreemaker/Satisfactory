local setmetatable = setmetatable
local getmetatable = getmetatable
local rawset = rawset
local rawget = rawget

local LoadedLoaderFiles = ({ ... })[1]
---@type object
local Object = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Object'][1]
---@type Utils.String
local String = LoadedLoaderFiles['/Github-Loading/Loader/Utils/String'][1]
---@type Utils.Table
local Table = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Table'][1]

---@class Utils.old.Class.MetaMethods
---@field __init (fun(self: object, ...) : ...)?
---@field __call (fun(self: object, ...) : ...)?
---@field __gc fun(self: object)?
---@field __add (fun(self: object, other: any) : any)? (self) + (value)
---@field __sub (fun(self: object, other: any) : any)? (self) - (value)
---@field __mul (fun(self: object, other: any) : any)? (self) * (value)
---@field __div (fun(self: object, other: any) : any)? (self) / (value)
---@field __mod (fun(self: object, other: any) : any)? (self) % (value)
---@field __pow (fun(self: object, other: any) : any)? (self) ^ (value)
---@field __idiv (fun(self: object, other: any) : any)? (self) // (value)
---@field __band (fun(self: object, other: any) : any)? (self) & (value)
---@field __bor (fun(self: object, other: any) : any)? (self) | (value)
---@field __bxor (fun(self: object, other: any) : any)? (self) ~ (value)
---@field __shl (fun(self: object, other: any) : any)? (self) << (value)
---@field __shr (fun(self: object, other: any) : any)? (self) >> (value)
---@field __concat (fun(self: object, other: any) : any)? (self) .. (value)
---@field __eq (fun(self: object, other: any) : any)? (self) == (value)
---@field __lt (fun(t1: any, t2: any) : any)? (self) < (value)
---@field __le (fun(t1: any, t2: any) : any)? (self) <= (value)
---@field __unm (fun(self: object) : any)? -(self)
---@field __bnot (fun(self: object) : any)?  ~(self)
---@field __len (fun(self: object) : any)? #(self)
---@field __pairs (fun(t: table) : ((fun(t: table, key: any) : key: any, value: any), t: table, startKey: any))? pairs(self)
---@field __ipairs (fun(t: table) : ((fun(t: table, key: number) : key: number, value: any), t: table, startKey: number))? ipairs(self)
---@field __tostring (fun(t):string)? tostring(self)
---@field __index fun(class, key) : any
---@field __newindex fun(class, key, value)

---@enum Utils.old.Class.ConstructorState
local ConstructorState = {
    Building = 0,
    Builded = 1,
    Running = 2,
    Finished = 3
}

---@class Utils.old.Class.Metatable : Utils.old.Class.MetaMethods
---@field Type string
---@field Base object
---@field IsBaseClass boolean
---@field ConstructorState Utils.old.Class.ConstructorState
---@field HasConstructor boolean
---@field HasDeconstructor boolean
---@field MetaMethods Utils.Class.MetaMethods
---@field StaticFunctions Dictionary<string, function>
---@field StaticProperties Dictionary<string, any>
---@field Functions Dictionary<string, function>
---@field Properties Dictionary<string, any>
---@field HasIndex boolean
---@field HasNewIndex boolean

---@class Utils.old.Class
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
    __call = true,
    __init = true
}

---@param class table
---@param metatable Utils.old.Class.Metatable
---@param key string
---@param value any
local function hasStringKey(class, metatable, key, value)
    local splittedKey = String.Split(key, '__')
    if not Table.Contains(splittedKey, 'Static') then
        if metatableMethods[key] then
            metatable.MetaMethods[key] = value
            class[key] = nil
        elseif type(value) == 'function' then
            metatable.Functions[key] = value
            class[key] = nil
        else
            metatable.Properties[key] = value
            class[key] = nil
        end
    else
        if type(value) == "function" then
            metatable.StaticFunctions[key] = value
            class[key] = nil
        else
            metatable.StaticProperties[key] = value
            class[key] = nil
        end
    end
end

---@param class table
---@param metatable Utils.old.Class.Metatable
local function HideMembers(class, metatable)
    ---@diagnostic disable-next-line
    metatable.MetaMethods = {}
    metatable.StaticFunctions = {}
    metatable.StaticProperties = {}
    metatable.Functions = {}
    metatable.Properties = {}
    for key, value in pairs(class) do
        if type(key) == 'string' then
            hasStringKey(class, metatable, key, value)
        else
            if type(value) == 'function' then
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
---@param metatable Utils.old.Class.Metatable
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
    metatable.Properties = nil
end

local overrideMetaMethods = {
    '__pairs',
    '__ipairs',
    '__len'
}
---@param metatable Utils.old.Class.Metatable
local function OverrideMetaMethods(metatable)
    for _, metaMethod in pairs(overrideMetaMethods) do
        if not metatable.MetaMethods[metaMethod] then
            ---@type Utils.Class.Metatable
            local baseClassMetatable = getmetatable(metatable.Base)
            local baseClassMetaMethod = baseClassMetatable.MetaMethods[metaMethod]
            if not baseClassMetaMethod then
                local function throwError()
                    error("can not use: '" .. metaMethod .. "' on class type: '" .. metatable.Type .. "'", 2)
                end
                metatable.MetaMethods[metaMethod] = throwError
            end
            metatable.MetaMethods[metaMethod] = baseClassMetaMethod
        end
    end
end

---@param class object
---@param key any
local function index(class, key)
    ---@type Utils.old.Class.Metatable
    local classMetatable = getmetatable(class)
    local value
    if classMetatable.HasIndex then
        value = classMetatable.MetaMethods.__index(class, key)
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

---@param class object
---@param key any
local function NotConstructedIndex(class, key)
    ---@type Utils.old.Class.Metatable
    local classMetatable = getmetatable(class)

    local staticProperty = classMetatable.StaticProperties[key]
    if staticProperty ~= nil then
        return staticProperty
    end

    local staticFunction = classMetatable.StaticFunctions[key]
    if staticFunction then
        return staticFunction
    end

    local baseStatic = classMetatable.Base[key]
    if baseStatic ~= nil then
        return baseStatic
    end

    error('cannot get values if class: ' .. classMetatable.Type .. ' was not constructed', 2)
end

---@param metatable Utils.old.Class.Metatable
local function BlockIndex(metatable)
    metatable.__index = NotConstructedIndex
end

---@param metatable Utils.old.Class.Metatable
local function UnBlockIndex(metatable)
    if metatable.HasIndex then
        metatable.__index = index
        return
    end
    metatable.__index = nil
end

---@param metatable Utils.old.Class.Metatable
local function AddIndex(metatable)
    local __index = metatable.MetaMethods.__index
    if type(__index) == 'function' then
        metatable.HasIndex = true
    else
        metatable.HasIndex = false
    end
end

---@param class object
local function NotConstructedNewIndex(class)
    ---@type Utils.old.Class.Metatable
    local classMetatable = getmetatable(class)
    error('cannot assign values if class: ' .. classMetatable.Type .. ' was not constructed', 2)
end

---@param metatable Utils.old.Class.Metatable
local function BlockNewIndex(metatable)
    metatable.__newindex = NotConstructedNewIndex
end

---@param metatable Utils.old.Class.Metatable
local function UnBlockNewIndex(metatable)
    if metatable.HasNewIndex then
        metatable.__newindex = metatable.MetaMethods.__newindex
        return
    end
    metatable.__newindex = nil
end

---@param metatable Utils.old.Class.Metatable
local function AddNewIndex(metatable)
    local __newindex = metatable.MetaMethods.__newindex
    if type(__newindex) == 'function' then
        metatable.HasNewIndex = true
        return
    end
    metatable.HasNewIndex = false
end

---@param metatable Utils.old.Class.Metatable
local function Block(metatable)
    BlockIndex(metatable)
    BlockNewIndex(metatable)
end

---@param metatable Utils.old.Class.Metatable
local function Free(metatable)
    metatable.__index = nil
    metatable.__newindex = nil
end

---@param metatable Utils.old.Class.Metatable
local function UnBlock(metatable)
    UnBlockIndex(metatable)
    UnBlockNewIndex(metatable)
end

---@param classMetatable Utils.old.Class.Metatable
---@param baseClass object
local function AddBaseClass(classMetatable, baseClass)
    classMetatable.Base = baseClass
    classMetatable.IsBaseClass = false
    ---@type Utils.Class.Metatable
    local baseClassMetatable = getmetatable(baseClass)
    baseClassMetatable.IsBaseClass = true
end

---@generic TBaseClass
---@param class TBaseClass
---@return TBaseClass
local function CopyIfNotBaseClass(class)
    ---@type Utils.old.Class.Metatable
    local classMetatable = getmetatable(class)
    if classMetatable.IsBaseClass then
        return class
    end
    return Utils.Table.Copy(class)
end

---@param metatable Utils.old.Class.Metatable
local function AddConstructor(metatable)
    ---@type fun(self: object, ...: any, base: object | nil)
    local constructor = metatable.MetaMethods.__init

    ---@param class object
    ---@param ... any
    local function construct(class, ...) ---@diagnostic disable-line: redefined-local
        class = CopyIfNotBaseClass(class)
        ---@type Utils.old.Class.Metatable
        local classMetatable = getmetatable(class)
        classMetatable.__call = nil
        classMetatable.ConstructorState = ConstructorState.Running
        ShowMembers(class, classMetatable)
        Free(classMetatable)
        setmetatable(class, classMetatable)

        local baseClass = classMetatable.Base
        ---@type Utils.old.Class.Metatable
        local baseClassMetatable = getmetatable(baseClass)

        if classMetatable.HasConstructor and baseClassMetatable.HasConstructor then
            if #{ ... } == 0 then
                constructor(class, baseClass)
            else
                constructor(class, ..., baseClass)
            end
            if baseClassMetatable.ConstructorState ~= ConstructorState.Finished then
                error("base class from class: '" .. classMetatable.Type .. "' did not get constructed or didn't finish",
                    2)
            end
        elseif classMetatable.HasConstructor and not baseClassMetatable.HasConstructor then
            baseClass = baseClass()
            constructor(class, ...)
        else
            baseClass = baseClass()
        end

        UnBlock(classMetatable)
        classMetatable.ConstructorState = ConstructorState.Finished
        return class
    end

    metatable.__call = construct
    if type(constructor) == 'function' then
        metatable.HasConstructor = true
        metatable.MetaMethods.__init = nil
        return
    end

    metatable.HasConstructor = false
    ---@type Utils.old.Class.Metatable
    local baseClassMetatable = getmetatable(metatable.Base)
    if baseClassMetatable.HasConstructor then
        error(
            "can not create class: '" ..
            metatable.Type ..
            "' with no constructor when the base class: '" .. baseClassMetatable.Type .. "' has a constructor", 3)
    end
end

---@param metatable Utils.old.Class.Metatable
local function AddDeconstructor(metatable)
    ---@type fun(class: object)?
    local deconstructor = metatable.MetaMethods.__gc

    ---@param class object
    local function deconstruct(class)
        ---@cast deconstructor fun(class: object)

        ---@type Utils.old.Class.Metatable
        local classMetatable = getmetatable(class)
        classMetatable.__gc = nil

        deconstructor(class)
    end

    if type(deconstructor) == 'function' then
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
---@param baseClass TBaseClass?
---@return TClass
function Class.CreateClass(class, classType, baseClass)
    baseClass = baseClass or Object
    baseClass = Utils.Table.Copy(baseClass) -- find new way of constructing class wich is faster
    if not Class.HasClassOfType(baseClass, 'object') then
        error('base class argument is not a class', 2)
    end
    ---@type Utils.old.Class.Metatable
    local classMetatable = getmetatable(class)
    if classMetatable == nil then
        ---@diagnostic disable-next-line
        classMetatable = {}
        setmetatable(class, classMetatable)
    end
    classMetatable.Type = classType
    classMetatable.ConstructorState = ConstructorState.Building
    ---@cast class table
    HideMembers(class, classMetatable)
    AddNewIndex(classMetatable)
    AddIndex(classMetatable)
    AddBaseClass(classMetatable, baseClass)
    AddDeconstructor(classMetatable)
    AddConstructor(classMetatable)
    OverrideMetaMethods(classMetatable)
    Block(classMetatable)
    classMetatable.ConstructorState = ConstructorState.Builded
    setmetatable(class, classMetatable)
    return class
end

---@param class object
---@param classType string
---@return boolean hasClassOfType
function Class.HasClassOfType(class, classType)
    ---@type Utils.old.Class.Metatable
    local metatable = getmetatable(class)
    if metatable.Type == classType then
        return true
    end
    if metatable.Type == 'object' then
        return false
    end
    return Class.HasClassOfType(metatable.Base, classType)
end

---@param class object
---@return object? base
function Class.GetBaseClass(class)
    ---@type Utils.old.Class.Metatable
    local classMetatable = getmetatable(class)
    return classMetatable.Base
end

return Class
