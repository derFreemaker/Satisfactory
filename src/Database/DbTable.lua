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
    while true do
        if self.m_current == self.m_length then
            return nil, nil
        end

        self.m_current = self.m_current + 1
        local nextKey = self.m_childs[self.m_current]

        if filesystem.exists(nextKey) then
            local nextValue = self.m_dbTable:Get(nextKey)
            self.m_dbTable:ObjectChanged(nextKey, nextValue)
            return nextKey, nextValue
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

class("Database.Iterator", Iterator)

---@generic TKey : string | integer
---@generic TValue : Core.Json.Serializable
---@class Database.DbTable<TKey, TValue> : object, { Load: (fun(self: Database.DbTable<TKey, TValue>)), Save: (fun(self: Database.DbTable<TKey, TValue>)), Add: (fun(self: Database.DbTable<TKey, TValue>, key: TKey, value: TValue)), Remove: (fun(self: Database.DbTable<TKey, TValue>, key: TKey) : boolean), Get: (fun(self: Database.DbTable<TKey, TValue>, key: TKey) : TValue), Iterator: (fun(self: Database.DbTable<TKey, TValue>) : Database.Iterator), Count: (fun() : integer) }
---@field package m_path Core.FileSystem.Path
---@field m_dataChanged table<string, any>
---@field m_keys table<string, true>
---@field m_count integer
---@field m_serializer Core.Json.Serializer
---@field m_logger Core.Logger 
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
    self.m_keys = {}
    self.m_count = 0
    self.m_logger = logger

    self.m_serializer = serializer or JsonSerializer.Static__Serializer
end

function DbTable:Load()
    self.m_logger:LogTrace("loading Database Table...")

    local parentFolder = self.m_path:GetParentFolderPath()
    if not filesystem.exists(parentFolder:GetPath()) then
        filesystem.createDir(parentFolder:GetPath(), true)
    end

    for _, value in pairs(filesystem.childs(parentFolder:GetPath())) do
        self.m_keys[value:match("^(.+)%.dto%.json$")] = true
    end
    self.m_count = #self.m_keys

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
function DbTable:Add(key, value)
    local path = self.m_path:Extend(tostring(key) .. ".dto.json")

    File.Static__WriteAll(path, self.m_serializer:Serialize(value))

    self.m_keys[key] = true
    self.m_count = self.m_count + 1
end

---@param key string | integer
---@return boolean success
function DbTable:Remove(key)
    local path = self.m_path:Extend(tostring(key) .. ".dto.json")

    self.m_keys[key] = nil
    self.m_count = self.m_count - 1

    return filesystem.remove(path:GetPath())
end

---@param key string | integer
---@return any value
function DbTable:Get(key)
    if not self.m_keys[key] then
        return nil
    end

    local path = self.m_path:Extend(key .. ".dto.json")
    if path:IsFile() and path:Exists() then
        local data = File.Static__ReadAll(path)
        local value = self.m_serializer:Deserialize(data)
        self:ObjectChanged(key, value)
        return value
    end

    self:Remove(key)
    return nil
end

---@return Database.Iterator
function DbTable:Iterator()
    return Iterator(self)
end

function DbTable:Count()
    return self.m_count
end

return class("Database.DbTable", DbTable)
