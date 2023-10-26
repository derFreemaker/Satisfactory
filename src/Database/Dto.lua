---@class Database.Dto : object
---@field private m_key any
---@field private m_data table
---@field private m_dbTable Database.DbTable
---@overload fun(key: any, data: table, dbTable: Database.DbTable) : Database.Dto
local Dto = {}

---@private
---@param key any
---@param data table
---@param dbTable Database.DbTable
function Dto:__init(key, data, dbTable)
    self.m_key = key
    self.m_data = data
    self.m_dbTable = dbTable
end

---@private
---@param key any
function Dto:__index(key)
    local value = self.m_data[key]

    if type(value) == "table" then
        return Dto(self.m_key, value, self.m_dbTable)
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

    self.m_data[key] = value
    self.m_dbTable:ObjectChanged(self.m_key)
end

return Utils.Class.CreateClass(Dto, "Database.Dto")
