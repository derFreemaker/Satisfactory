local JsonSerializer = require("Core.Json.JsonSerializer")
local File = require("Core.FileSystem.File")

---@class Database.DbTable : object
---@field private m_name string
---@field private m_path Core.FileSystem.Path
---@field private m_dataChanged table<string | number, any>
---@field private m_logger Core.Logger
---@field private m_serializer Core.Json.Serializer
---@overload fun(name: string, path: Core.FileSystem.Path, logger: Core.Logger, serializer: Core.Json.Serializer?) : Database.DbTable
local DbTable = {}

---@private
---@param name string
---@param path Core.FileSystem.Path
---@param logger Core.Logger
---@param serializer Core.Json.Serializer
function DbTable:__init(name, path, logger, serializer)
    if not path:IsDir() then
        error("path needs to be a folder: " .. path:GetPath())
    end

    if not filesystem.exists(path:GetPath()) then
        filesystem.createDir(path:GetPath(), true)
    end

    self.m_name = name
    self.m_path = path
    self.m_dataChanged = {}
    self.m_logger = logger

    self.m_serializer = serializer or JsonSerializer.Static__Serializer
end

function DbTable:Load()
    self.m_logger:LogTrace("loading Database Table: '" .. self.m_name .. "'...")

    local parentFolder = self.m_path:GetParentFolderPath()
    if not filesystem.exists(parentFolder:GetPath()) then
        filesystem.createDir(parentFolder:GetPath(), true)
    end

    self.m_logger:LogTrace("loaded Database Table")
end

function DbTable:Save()
    self.m_logger:LogTrace("saving Database Table: '" .. self.m_name .. "'...")

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
function DbTable:Delete(key)
    local path = self.m_path:Extend(tostring(key) .. ".dto.json")

    filesystem.remove(path:GetPath())
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
            end
        end
    end

    if value ~= nil then
        self:ObjectChanged(key, value)
    end
    return value
end

---@private
---@return (fun(t: table, key: any) : key: any, value: any), table t, any startKey
function DbTable:__pairs()
    local childs = filesystem.childs(self.m_path:GetPath())

    local function iterator(tbl, key)
        local nextFile
        if key == nil then
            nextFile = next(tbl, key)
        else
            nextFile = next(tbl, key .. ".dto.json")
        end
        if nextFile == nil then
            return nil, nil
        end

        local nextKey = nextFile:match("^(.+)%.dto%.json$")
        local nextValue = self:Get(nextKey)
        return nextKey, nextValue
    end

    return iterator, Utils.Table.Invert(childs), nil
end

return Utils.Class.CreateClass(DbTable, "Database.DbTable")
