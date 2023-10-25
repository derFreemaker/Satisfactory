local JsonSerializer = require("Core.Json.JsonSerializer")
local File = require("Core.FileSystem.File")

local Dto = require("Database.Dto")

---@class Database.DbTable : object
---@field private _Name string
---@field private _Path Core.FileSystem.Path
---@field private _Data Dictionary<string | number, table>
---@field private _DataChanged (string | number)[]
---@field private _Logger Core.Logger
---@field private _Serializer Core.Json.Serializer
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

    self._Name = name
    self._Path = path
    self._Logger = logger
    self._Data = {}

    self._Serializer = serializer or JsonSerializer.Static__Serializer
end

function DbTable:Load()
    self._Logger:LogTrace("loading Database Table: '" .. self._Name .. "'...")
    local parentFolder = self._Path:GetParentFolderPath()
    if not filesystem.exists(parentFolder:GetPath()) then
        filesystem.createDir(parentFolder:GetPath(), true)
    end

    for _, fileName in ipairs(filesystem.childs(self._Path:GetPath())) do
        local path = self._Path:Extend(fileName)

        if path:IsFile() then
            local data = File.Static__ReadAll(path)

            local key = fileName:match("^(.+)%.dto%.json$")
            self._Data[key] = self._Serializer:Deserialize(data)
        end
    end

    self._Logger:LogTrace("loaded Database Table")
end

function DbTable:Save()
    self._Logger:LogTrace("saving Database Table: '" .. self._Name .. "'...")

    for _, key in pairs(self._DataChanged) do
        local path = self._Path:Extend(tostring(key) .. ".dto.json")
        local data = self._Data[key]

        if not data then
            filesystem.remove(path:GetPath())
        else
            File.Static__WriteAll(path, self._Serializer:Serialize(data))
        end
    end

    self._Logger:LogTrace("saved Database Table")
end

---@param key string | number | Core.Json.Serializable
function DbTable:ObjectChanged(key)
    for _, value in pairs(self._DataChanged) do
        if value == key then
            return
        end
    end

    table.insert(self._DataChanged, key)
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

        key = self._Serializer:Serialize(key)
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
    if self._Serializer:TryDeserialize(key, outObj) then
        return outObj.Value
    end

    return key
end

---@param key string | number | Core.Json.Serializable
---@param value table
function DbTable:Set(key, value)
    key = self:_FormatKeyForStorage(key)
    self._Data[key] = value
    self:ObjectChanged(key)
end

---@param key string | number | Core.Json.Serializable
function DbTable:Delete(key)
    key = self:_FormatKeyForStorage(key)
    self._Data[key] = nil
    self:ObjectChanged(key)
end

---@param key string | number | Core.Json.Serializable
---@return table value
function DbTable:Get(key)
    key = self:_FormatKeyForStorage(key)
    local data = self._Data[key]
    return Dto(key, data, self)
end

---@private
---@return (fun(t: table, key: any) : key: any, value: any), table t, any startKey
function DbTable:__pairs()
    ---@type Database.Dto[]
    local dtoObjs = {}

    for key, value in pairs(self._Data) do
        dtoObjs[key] = Dto(self:_FormatKeyForUsage(key), value, self)
    end

    return next, dtoObjs, nil
end

return Utils.Class.CreateClass(DbTable, "Database.DbTable")
