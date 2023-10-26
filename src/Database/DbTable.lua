local JsonSerializer = require("Core.Json.JsonSerializer")
local File = require("Core.FileSystem.File")

local Dto = require("Database.Dto")

---@class Database.DbTable : object
---@field private m_name string
---@field private m_path Core.FileSystem.Path
---@field private m_data Dictionary<string | number, table>
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
    self.m_logger = logger
    self.m_data = {}

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

---@param key string | number | Core.Json.Serializable
function DbTable:ObjectChanged(key)
    for _, value in pairs(self.m_dataChanged) do
        if value == key then
            return
        end
    end

    table.insert(self.m_dataChanged, key)
end

---@private
---@param key string | number | Core.Json.Serializable
---@return string | number
function DbTable:_FormatKeyForStorage(key)
    local typeName = type(key)
    if typeName ~= "string" and typeName ~= "number" then
        if not Utils.Class.HasBaseClass(key, "Core.Json.Serializable") then
            error("key is not a string, number or Serializable")
        end

        key = self.m_serializer:Serialize(key)
        ---@cast key string
    end

    return key
end

---@private
---@param key string | number
---@return string | number | Core.Json.Serializable
function DbTable:_FormatKeyForUsage(key)
    if type(key) == "number" then
        return key
    end

    ---@type Out<any>
    local outObj = {}
    if self.m_serializer:TryDeserialize(key, outObj) then
        return outObj.Value
    end

    return key
end

---@param key string | number | Core.Json.Serializable
---@param value table
function DbTable:Set(key, value)
    key = self:_FormatKeyForStorage(key)
    self.m_data[key] = value
    self:ObjectChanged(key)
end

---@param key string | number | Core.Json.Serializable
function DbTable:Delete(key)
    key = self:_FormatKeyForStorage(key)
    self.m_data[key] = nil
    self:ObjectChanged(key)
end

---@param key string | number | Core.Json.Serializable
---@return table value
function DbTable:Get(key)
    key = self:_FormatKeyForStorage(key)
    local data = self.m_data[key]
    return Dto(key, data, self)
end

---@private
---@return (fun(t: table, key: any) : key: any, value: any), table t, any startKey
function DbTable:__pairs()
    ---@type Database.Dto[]
    local dtoObjs = {}

    for key, value in pairs(self.m_data) do
        dtoObjs[key] = Dto(self:_FormatKeyForUsage(key), value, self)
    end

    return next, dtoObjs, nil
end

return Utils.Class.CreateClass(DbTable, "Database.DbTable")
