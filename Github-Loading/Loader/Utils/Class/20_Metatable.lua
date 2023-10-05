local rawget = rawget

local LoadedLoaderFiles = ({ ... })[1]
---@type Utils.String
local String = LoadedLoaderFiles['/Github-Loading/Loader/Utils/String'][1]
---@type Utils.Table
local Table = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Table'][1]

---@class Utils.Class.MetaMethods
---@field __init (fun(self: object, ...))? self(...) before construction
---@field __call (fun(self: object, ...) : ...)? self(...) after construction
---@field __gc fun(self: object)? Utils.Class.Deconstruct(self) or garbageCollection
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
---@field __index (fun(class, key) : any)? xxx = self.xxx | self[xxx]
---@field __newindex fun(class, key, value)? self.xxx | self[xxx] = xxx

---@class Utils.Class.CustomMetaMethods
---@field Constructor (fun(self: object, ...))? self(...) before construction
---@field Deconstructor fun(self: object)? Class.Deconstruct(self) or garbageCollection
---@field __call (fun(self: object, ...) : ...)? self(...) after construction
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
---@field __index (fun(class, key) : any)? xxx = self.xxx | self[xxx]
---@field __newindex fun(class, key, value)? self.xxx | self[xxx] = xxx

---@class Utils.Class.Metatable : Utils.Class.MetaMethods
---@field Type string
---@field Base object
---
---@field MetaMethods Utils.Class.CustomMetaMethods
---@field HasMetaMethods string[]
---
---@field HasConstructor boolean
---@field HasDeconstructor boolean
---@field HasIndex boolean
---@field HasNewIndex boolean
---@field IsBaseClass boolean
---
---@field ConstructionState Utils.Class.ConstructionState

local overrideableMetaMethods = {
    __pairs = "__pairs",
    __ipairs = "__ipairs"
}

local notOverrideableMetaMethods = {
    __init = "Constructor",
    __gc = "Deconstructor",
    __call = "__call",
    __index = "__index",
    __newindex = "__newindex",
    __add = "__add",
    __sub = "__sub",
    __mul = "__mul",
    __div = "__div",
    __mod = "__mod",
    __pow = "__pow",
    __unm = "__unm",
    __idiv = "__idiv",
    __band = "__band",
    __bor = "__bor",
    __bxor = "__bxor",
    __bnot = "__bnot",
    __shl = "__shl",
    __shr = "__shr",
    __concat = "__concat",
    __len = "__len",
    __eq = "__eq",
    __lt = "__lt",
    __le = "__le",
    __tostring = "__tostring",
}

---@param class object
---@param metatable Utils.Class.Metatable
---@param key string
---@param value any
local function notStaticFunction(class, metatable, key, value)
    local metaMethodName = overrideableMetaMethods[key] or notOverrideableMetaMethods[key]
    if metaMethodName then
        metatable.MetaMethods[metaMethodName] = value
        table.insert(metatable.HasMetaMethods, metaMethodName)
        class[key] = nil
        return
    end
end

---@param class object
---@param metatable Utils.Class.Metatable
local function SortMetaMethods(class, metatable)
    ---@diagnostic disable-next-line
    metatable.MetaMethods = {}
    metatable.HasMetaMethods = {}
    for key, value in pairs(class) do
        if type(value) == "function" and type(key) == 'string' then
            local splittedKey = String.Split(key, '__')
            if not Table.Contains(splittedKey, 'Static') then
                notStaticFunction(class, metatable, key, value)
            end
        end
    end
end

local SearchValueInBase = {}

---@param class object
---@param key any
local function index(class, key)
    ---@type Utils.Class.Metatable
    local classMetatable = getmetatable(class)
    local value
    if classMetatable.HasIndex then
        value = classMetatable.MetaMethods.__index(class, key)
    else
        value = rawget(class, key) or SearchValueInBase
    end
    if value ~= SearchValueInBase then
        return value
    end
    local baseClass = classMetatable.Base
    value = baseClass[key]
    return value
end

---@class Utils.Class.Modifier.Metatable
local Metatable = {}

---@param class object
---@param metatable Utils.Class.Metatable
function Metatable.Prepare(class, metatable)
    SortMetaMethods(class, metatable)
end

---@param metatable Utils.Class.Metatable
function Metatable.BlockMetaMethods(metatable)
    local base = metatable.Base
    local type = metatable.Type

    for _, metaMethod in pairs(overrideableMetaMethods) do
        local function throwError()
            error("can not use metaMethod: '" .. metaMethod .. "' on class type: '" .. type .. "'", 2)
        end
        metatable[metaMethod] = throwError
    end

    ---@param class object
    ---@param key any
    local function NotConstructedIndex(class, key)
        local splittedKey = String.Split(key, '__')
        if not Table.Contains(splittedKey, 'Static') then
            error('cannot get values if class: ' .. type .. ' was not constructed', 2)
        end

        local static = rawget(class, key)
        if static ~= nil then
            return static
        end

        local baseStatic = base[key]
        if baseStatic ~= nil then
            return baseStatic
        end
    end
    metatable.__index = NotConstructedIndex

    local function NotConstructedNewIndex()
        error('cannot assign values if class: ' .. type .. ' was not constructed', 2)
    end
    metatable.__newindex = NotConstructedNewIndex
end

---@param metatable Utils.Class.Metatable
function Metatable.FreeMetaMethods(metatable)
    metatable.__index = nil
    metatable.__newindex = nil
end

---@param metatable Utils.Class.Metatable
function Metatable.UnBlockMetaMethods(metatable)
    for _, metaMethodName in pairs(metatable.HasMetaMethods) do
        metatable[metaMethodName] = metatable.MetaMethods[metaMethodName]
    end

    metatable.__index = index
end

---@param metatable Utils.Class.Metatable
function Metatable.Deconstruct(metatable)
    local type = metatable.Type

    for _, metaMethodName in pairs(metatable.HasMetaMethods) do
        local function throwError()
            error("can not use metaMethod: '" .. metaMethodName .. "' on class type: '" .. type .. "'", 2)
        end
        metatable[metaMethodName] = throwError()
    end

    local function deconstructedIndex()
        error("cannot get values from deconstructed class: '" .. type .. "'", 2)
    end
    metatable.__index = deconstructedIndex

    local function deconstructedNewIndex()
        error("cannot assign values from deconstructed class: '" .. type .. "'", 2)
    end
    metatable.__newindex = deconstructedNewIndex
end

return Metatable, SearchValueInBase
