---@meta
local PackageData = {}

PackageData["DatabaseDbTable"] = {
    Location = "Database.DbTable",
    Namespace = "Database.DbTable",
    IsRunnable = true,
    Data = [[
local JsonSerializer = require("Core.Json.JsonSerializer")
local File = require("Core.FileSystem.File")

---@class Database.DbTable : object
---@field private m_name string
---@field private m_path Core.FileSystem.Path
---@field private m_data table<string | number, any>
---@field private m_dataChanged (string | number)[]
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
    self.m_data = {}
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

    for _, fileName in ipairs(filesystem.childs(self.m_path:GetPath())) do
        local path = self.m_path:Extend(fileName)

        if path:IsFile() then
            local data = File.Static__ReadAll(path)

            local key = fileName:match("^(.+)%.dto%.json$")
            self.m_data[key] = self.m_serializer:Deserialize(data)
        end
    end

    self.m_logger:LogTrace("loaded Database Table")
end

function DbTable:Save()
    self.m_logger:LogTrace("saving Database Table: '" .. self.m_name .. "'...")

    for _, key in pairs(self.m_dataChanged) do
        local path = self.m_path:Extend(tostring(key) .. ".dto.json")
        local data = self.m_data[key]

        if not data then
            filesystem.remove(path:GetPath())
        else
            File.Static__WriteAll(path, self.m_serializer:Serialize(data))
        end
    end

    self.m_logger:LogTrace("saved Database Table")
end

---@param key string | integer
function DbTable:ObjectChanged(key)
    for _, value in pairs(self.m_dataChanged) do
        if value == key then
            return
        end
    end

    table.insert(self.m_dataChanged, key)
end

---@param key string | integer
---@param value any
function DbTable:Set(key, value)
    self.m_data[key] = value
    self:ObjectChanged(key)
end

---@param key string | integer
function DbTable:Delete(key)
    self.m_data[key] = nil
    self:ObjectChanged(key)
end

---@param key string | integer
---@return any value
function DbTable:Get(key)
    local value = self.m_data[key]
    self:ObjectChanged(key)
    return value
end

---@private
---@return (fun(t: table, key: any) : key: any, value: any), table t, any startKey
function DbTable:__pairs()
    local function iterator(tbl, key)
        local nextKey, nextValue = next(tbl, key)
        self:ObjectChanged(key)
        return nextKey, nextValue
    end

    return iterator, self.m_data, nil
end

return Utils.Class.CreateClass(DbTable, "Database.DbTable")
]]
}

return PackageData
