local JsonSerializer = require("Core.Json.JsonSerializer")
local File = require("Core.FileSystem.File")

local Entity = require("Core.Database.Entity")
local Iterator = require("Core.Database.Iterator")

---@class Core.Database.Table<TKey, TValue> : object, { Load: (fun(self: Core.Database.Table<TKey, TValue>)), Save: (fun(self: Core.Database.Table<TKey, TValue>)), Add: (fun(self: Core.Database.Table<TKey, TValue>, key: TKey, value: TValue) : TValue), Remove: (fun(self: Core.Database.Table<TKey, TValue>, key: TKey) : boolean), Get: (fun(self: Core.Database.Table<TKey, TValue>, key: TKey) : TValue), Iterator: (fun(self: Core.Database.Table<TKey, TValue>) : Core.Database.Iterator), Count: (fun() : integer) }
---@field m_path Core.FileSystem.Path
---@field m_dataChanged table<string, any>
---@field m_keys table<string, true>
---@field m_count integer
---@field m_serializer Core.Json.Serializer
---@field m_logger Core.Logger 
---@overload fun(path: Core.FileSystem.Path, logger: Core.Logger, serializer: Core.Json.Serializer | nil) : Core.Database.Table
local DbTable = {}

---@private
---@param path Core.FileSystem.Path
---@param logger Core.Logger
---@param serializer Core.Json.Serializer | nil
function DbTable:__init(path, logger, serializer)
    if not path:IsDir() then
        error("path needs to be a directory: " .. path:ToString())
    end

    if not filesystem.exists(path:ToString()) then
        filesystem.createDir(path:ToString(), true)
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
    if not filesystem.exists(parentFolder:ToString()) then
        filesystem.createDir(parentFolder:ToString(), true)
    end

    for _, value in pairs(filesystem.childs(parentFolder:ToString())) do
        self.m_keys[value:match("^(.+)%.dto%.json$")] = true
    end
    self.m_count = #self.m_keys

    self.m_logger:LogTrace("loaded Database Table")
end

function DbTable:Save()
    self.m_logger:LogTrace("saving Database Table...")

    for key, value in pairs(self.m_dataChanged) do
        local path = self.m_path:Extend(tostring(key) .. ".dto.json")

        File.Static__WriteAll(path, self.m_serializer:Serialize(value))
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

---@return Core.FileSystem.Path
function DbTable:GetPath()
    return self.m_path
end

---@param key string | integer
---@param value any
---@return any value
function DbTable:Add(key, value)
    self:ObjectChanged(key, value)

    self.m_keys[key] = true
    self.m_count = self.m_count + 1

    return Entity(key, value, self)
end

---@param key string | integer
---@return boolean success
function DbTable:Remove(key)
    local path = self.m_path:Extend(tostring(key) .. ".dto.json")

    self.m_keys[key] = nil
    self.m_count = self.m_count - 1

    return filesystem.remove(path:ToString())
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
        return Entity(key, value, self)
    end

    self:Remove(key)
    return nil
end

---@return Core.Database.Iterator
function DbTable:Iterator()
    return Iterator(self)
end

function DbTable:Count()
    return self.m_count
end

return class("Database.DbTable", DbTable)
