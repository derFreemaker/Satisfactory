local JsonSerializer = require("Core.Json.JsonSerializer")
local File = require("Core.FileSystem.File")

---@class Database.Iterator<TKey, TValue> : object
---@field m_dbTable Database.DbTable
---@field m_childs string[]
---@field m_current string | integer
---@field m_length integer
---@overload fun(dbTable: Database.DbTable) : Database.Iterator
local Iterator = {}

---@private
---@param dbTable Database.DbTable
function Iterator:__init(dbTable)
    self.m_dbTable = dbTable
    self.m_childs = filesystem.childs(dbTable.m_path:GetPath())
    self.m_length = #self.m_childs
end

---@return string | integer | nil key, any value
function Iterator:Next()
    if self.m_current > self.m_length then
        return nil, nil
    end
    self.m_current = self.m_current + 1

    local nextKey = self.m_childs[self.m_current]
    local nextValue = self.m_dbTable:Get(nextKey)
    self.m_dbTable:ObjectChanged(nextKey, nextValue)

    return nextKey, nextValue
end

---@private
---@return fun() : key: string | integer | nil, value: any
function Iterator:__pairs()
    return function()
        return self:Next()
    end
end

class("Database.Iterator", Iterator)

---@generic TKey : string | integer
---@generic TValue : Core.Json.Serializable
---@class Database.DbTable<TKey, TValue> : object, { Load: (fun(self: Database.DbTable<TKey, TValue>)), Save: (fun(self: Database.DbTable<TKey, TValue>)), Set: (fun(self: Database.DbTable<TKey, TValue>, key: TKey, value: TValue)), Delete: (fun(self: Database.DbTable<TKey, TValue>, key: TKey) : boolean), Get: (fun(self: Database.DbTable<TKey, TValue>, key: TKey) : TValue), Iterator: (fun(self: Database.DbTable<TKey, TValue>) : Database.Iterator) }
---@field package m_path Core.FileSystem.Path
---@field m_dataChanged table<string | number, any>
---@field m_logger Core.Logger
---@field m_serializer Core.Json.Serializer
---@overload fun(path: Core.FileSystem.Path, logger: Core.Logger, serializer: Core.Json.Serializer?) : Database.DbTable
local DbTable = {}

---@private
---@param path Core.FileSystem.Path
---@param logger Core.Logger
---@param serializer Core.Json.Serializer
function DbTable:__init(path, logger, serializer)
    if not path:IsDir() then
        error("path needs to be a directory: " .. path:GetPath())
    end

    if not filesystem.exists(path:GetPath()) then
        filesystem.createDir(path:GetPath(), true)
    end

    self.m_path = path
    self.m_dataChanged = {}
    self.m_logger = logger

    self.m_serializer = serializer or JsonSerializer.Static__Serializer
end

function DbTable:Load()
    self.m_logger:LogTrace("loading Database Table...")

    local parentFolder = self.m_path:GetParentFolderPath()
    if not filesystem.exists(parentFolder:GetPath()) then
        filesystem.createDir(parentFolder:GetPath(), true)
    end

    self.m_logger:LogTrace("loaded Database Table")
end

function DbTable:Save()
    self.m_logger:LogTrace("saving Database Table...")

    for key, value in pairs(self.m_dataChanged) do
        local path = self.m_path:Extend(tostring(key) .. ".dto.json")

        if not value then
            filesystem.remove(path:GetPath())
        else
            File.Static__WriteAll(path, self.m_serializer:Serialize(value))
        end
    end

    self.m_logger:LogTrace("saved Database Table")
end

---@param key string | integer
---@param value any
function DbTable:ObjectChanged(key, value)
    if Utils.Table.ContainsKey(self.m_dataChanged, key) then
        return
    end

    self.m_dataChanged[key] = value
end

---@param key string | integer
---@param value any
function DbTable:Set(key, value)
    local path = self.m_path:Extend(tostring(key) .. ".dto.json")

    if not value then
        filesystem.remove(path:GetPath())
    else
        File.Static__WriteAll(path, self.m_serializer:Serialize(value))
    end
end

---@param key string | integer
---@return boolean success
function DbTable:Delete(key)
    local path = self.m_path:Extend(tostring(key) .. ".dto.json")

    return filesystem.remove(path:GetPath())
end

---@param key string | integer
---@return any value
function DbTable:Get(key)
    local value = nil
    for _, fileName in ipairs(filesystem.childs(self.m_path:GetPath())) do
        local path = self.m_path:Extend(fileName)

        if path:IsFile() then
            local fileKey = fileName:match("^(.+)%.dto%.json$")
            if key == fileKey then
                local data = File.Static__ReadAll(path)
                value = self.m_serializer:Deserialize(data)
                self:ObjectChanged(key, value)
                return value
            end
        end
    end
end

---@return Database.Iterator
function DbTable:Iterator()
    return Iterator(self)
end

return class("Database.DbTable", DbTable)
