local Entity = require("Core.Database.Entity")

---@class Core.Database.Iterator : object
---@field m_dbTable Core.Database.Table
---@field m_childs string[]
---@field m_current string | integer
---@field m_length integer
---@overload fun(dbTable: Core.Database.Table) : Core.Database.Iterator
local Iterator = {}

---@private
---@param dbTable Core.Database.Table
function Iterator:__init(dbTable)
    self.m_dbTable = dbTable
    self.m_childs = filesystem.childs(dbTable:GetPath():ToString())
    self.m_length = #self.m_childs
end

---@return string | integer | nil key, any value
function Iterator:Next()
    while true do
        if self.m_current == self.m_length then
            return nil, nil
        end

        self.m_current = self.m_current + 1
        local nextKey = self.m_childs[self.m_current]

        if filesystem.exists(nextKey) then
            local nextValue = self.m_dbTable:Get(nextKey)
            self.m_dbTable:ObjectChanged(nextKey, nextValue)
            return nextKey, Entity(nextKey, nextValue, self.m_dbTable)
        end
    end
end

---@private
---@return fun() : key: string | integer | nil, value: any
function Iterator:__pairs()
    return function()
        return self:Next()
    end
end

return class("Database.Iterator", Iterator)
