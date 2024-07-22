---@class Core.Database.Entity : object
---@field m_key string | integer
---@field m_obj object
---@field m_dbTable Core.Database.Table
---@overload fun(key: string | integer, obj: any, dbTable: Core.Database.Table) : Core.Database.Entity
local Entity = {}

---@private
---@param key string | integer
---@param obj any
---@param dbTable Core.Database.Table
function Entity:__init(key, obj, dbTable)
    self.m_key = key
    self.m_obj = obj
    self.m_dbTable = dbTable
end

---@private
function Entity:__index(key)
    self.m_dbTable:ObjectChanged(self.m_key, self.m_obj)
    return self.m_obj[key]
end

---@private
function Entity:__newindex(key, value)
    self.m_dbTable:ObjectChanged(self.m_key, self.m_obj)
    self.m_obj[key] = value
end

return class("Core.Database.Entity", Entity)
