---@class Database.Dto : object
---@field private key string | number
---@field private data table
---@field private dbTable Database.DbTable
---@overload fun(key: string | number, data: table, dbTable: Database.DbTable) : Database.Dto
local Dto = {}

---@private
---@param key string | number
---@param data table
---@param dbTable Database.DbTable
function Dto:__init(key, data, dbTable)
    self.key = key
    self.data = data
    self.dbTable = dbTable
end

---@private
---@param key boolean | string | number | table
function Dto:__index(key)
    return self.data[key]
end

---@pivate
---@param key boolean | string | number | table
---@param value Json.SerializeableTypes
function Dto:__newindex(key, value)
    local keyType = type(key)

    if not (keyType == "boolean" or keyType == "string" or keyType == "number" or keyType == "table") then
        error("unsupported key type: " .. keyType)
    end

    self.data[key] = value
    self.dbTable:ObjectChanged(self.key)
end

return Utils.Class.CreateClass(Dto, "Database.Dto")
