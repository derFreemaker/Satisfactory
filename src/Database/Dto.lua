---@class Database.Dto : object
---@field private _Key string | number | Core.Json.Serializable
---@field private _Data table
---@field private _DbTable Database.DbTable
---@overload fun(key: string | number | Core.Json.Serializable, data: table, dbTable: Database.DbTable) : Database.Dto
local Dto = {}

---@private
---@param key string | number | Core.Json.Serializable
---@param data table
---@param dbTable Database.DbTable
function Dto:__init(key, data, dbTable)
    self._Key = key
    self._Data = data
    self._DbTable = dbTable
end

---@private
---@param key boolean | string | number | table
function Dto:__index(key)
    self._DbTable:ObjectChanged(self._Key)
    return self._Data[key]
end

---@pivate
---@param key boolean | string | number | table
---@param value Json.SerializeableTypes
function Dto:__newindex(key, value)
    local keyType = type(key)

    if not (keyType == "boolean" or keyType == "string" or keyType == "number" or keyType == "table") then
        error("unsupported key type: " .. keyType)
    end

    self._Data[key] = value
    self._DbTable:ObjectChanged(self._Key)
end

return Utils.Class.CreateClass(Dto, "Database.Dto")
