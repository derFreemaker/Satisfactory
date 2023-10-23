---@class Database.Dto : object
---@field private _Key any
---@field private _Data table
---@field private _DbTable Database.DbTable
---@overload fun(key: any, data: table, dbTable: Database.DbTable) : Database.Dto
local Dto = {}

---@private
---@param key any
---@param data table
---@param dbTable Database.DbTable
function Dto:__init(key, data, dbTable)
    self._Key = key
    self._Data = data
    self._DbTable = dbTable
end

---@private
---@param key any
function Dto:__index(key)
    local value = self._Data[key]

    if type(value) == "table" then
        return Dto(self._Key, value, self._DbTable)
    end

    return value
end

---@pivate
---@param key any
---@param value Json.SerializeableTypes
function Dto:__newindex(key, value)
    local keyType = type(key)
    if keyType ~= "string" and keyType ~= "number" and keyType ~= "table" then
        error("unsupported key type: " .. keyType)
    end

    local valueType = type(value)
    if valueType ~= "boolean" and valueType ~= "string" and valueType ~= "number" and valueType ~= "table" and valueType ~= "nil" then
        error("unsupported value type: " .. valueType)
    end

    self._Data[key] = value
    self._DbTable:ObjectChanged(self._Key)
end

return Utils.Class.CreateClass(Dto, "Database.Dto")
