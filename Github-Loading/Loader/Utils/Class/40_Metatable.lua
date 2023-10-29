local LoadedLoaderFiles = ({ ... })[1]
---@type Utils.Class.Configs
local Configs = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Class/Config'][1]
---@type Utils.String
local String = LoadedLoaderFiles['/Github-Loading/Loader/Utils/String'][1]
---@type Utils.Table
local Table = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Table'][1]
---@type Utils.Class.TypeHandler
local TypeHandler = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Class/Type'][1]

---@class Utils.Class.MetaMethods
---@field __init (fun(self: object, ...))? self(...) before construction
---@field __gc fun(self: object)? Class.Deconstruct(self) or garbageCollection
---@field __call (fun(self: object, ...) : ...)? self(...) after construction
---@field __index (fun(class: object, key: any) : any)? xxx = self.xxx | self[xxx]
---@field __newindex fun(class: object, key: any, value: any)? self.xxx | self[xxx] = xxx
---@field __tostring (fun(t):string)? tostring(self)
---@field __add (fun(left: any, right: any) : any)? (left) + (right)
---@field __sub (fun(left: any, right: any) : any)? (left) - (right)
---@field __mul (fun(left: any, right: any) : any)? (left) * (right)
---@field __div (fun(left: any, right: any) : any)? (left) / (right)
---@field __mod (fun(left: any, right: any) : any)? (left) % (right)
---@field __pow (fun(left: any, right: any) : any)? (left) ^ (right)
---@field __idiv (fun(left: any, right: any) : any)? (left) // (right)
---@field __band (fun(left: any, right: any) : any)? (left) & (right)
---@field __bor (fun(left: any, right: any) : any)? (left) | (right)
---@field __bxor (fun(left: any, right: any) : any)? (left) ~ (right)
---@field __shl (fun(left: any, right: any) : any)? (left) << (right)
---@field __shr (fun(left: any, right: any) : any)? (left) >> (right)
---@field __concat (fun(left: any, right: any) : any)? (left) .. (right)
---@field __eq (fun(left: any, right: any) : any)? (left) == (right)
---@field __lt (fun(left: any, right: any) : any)? (left) < (right)
---@field __le (fun(left: any, right: any) : any)? (left) <= (right)
---@field __unm (fun(self: object) : any)? -(self)
---@field __bnot (fun(self: object) : any)?  ~(self)
---@field __len (fun(self: object) : any)? #(self)
---@field __pairs (fun(self: object) : ((fun(t: table, key: any) : key: any, value: any), t: table, startKey: any))? pairs(self)
---@field __ipairs (fun(self: object) : ((fun(t: table, key: number) : key: number, value: any), t: table, startKey: number))? ipairs(self)

---@class Utils.Class.Metatable : Utils.Class.MetaMethods
---@field Type Utils.Class.Type

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
            return TypeHandler.GetStatic(typeInfo, key)
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
            TypeHandler.SetStatic(typeInfo, key, value)
            return
        end

        error("can only use static members in template")
    end
    metatable.__newindex = newindex

    for key, _ in pairs(Configs.OverrideMetaMethods) do
        local function blockMetaMethod()
            error("cannot use meta method: " .. key .. " on a template from a class")
        end
        ---@diagnostic disable-next-line: assign-type-mismatch
        metatable[key] = blockMetaMethod
    end

    return metatable
end

---@param typeInfo Utils.Class.Type
---@param metatable Utils.Class.Metatable
function MetatableHandler.CreateMetatable(typeInfo, metatable)
    metatable.Type = typeInfo

    ---@param obj object
    ---@param key any
    ---@return any value
    local function index(obj, key)
        if type(key) == "string" then
            local splittedKey = String.Split(key, "__")
            if Table.Contains(splittedKey, "Static") then
                return TypeHandler.GetStatic(typeInfo, key)
            end
        end

        if typeInfo.HasIndex and not typeInfo.IndexingDisabled then
            local value = typeInfo.MetaMethods.__index(obj, key)
            if value ~= Configs.SearchInBase then
                return value
            end
        end

        return rawget(obj, key)
    end
    metatable.__index = index

    ---@param obj object
    ---@param key any
    ---@param value any
    local function newindex(obj, key, value)
        if type(key) == "string" then
            local splittedKey = String.Split(key, "__")
            if Table.Contains(splittedKey, "Static") then
                TypeHandler.SetStatic(typeInfo, key, value)
                return
            end
        end

        if typeInfo.HasNewIndex and not typeInfo.IndexingDisabled then
            if typeInfo.MetaMethods.__newindex(obj, key, value) ~= Configs.SetNormal then
                return
            end
        end

        return rawset(obj, key, value)
    end
    metatable.__newindex = newindex

    for key, _ in pairs(Configs.OverrideMetaMethods) do
        if not Table.ContainsKey(typeInfo.MetaMethods, key) then
            local function blockMetaMethod()
                error("cannot use meta method: " .. key .. " on class: " .. typeInfo.Name)
            end
            metatable[key] = blockMetaMethod
        end
    end
end

return MetatableHandler
