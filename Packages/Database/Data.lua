local PackageData = {}

PackageData[986863927] = {
    Location = "Database.DbTable",
    Namespace = "Database.DbTable",
    IsRunnable = true,
    Data = [[
local Json = require("Core.Json")

---@class Database.DbTable : object
---@field private name string
---@field private path Core.Path
---@field private data Dictionary<string | number, table>
---@field private logger Core.Logger
---@overload fun(name: string, path: Core.Path, logger: Core.Logger) : Database.DbTable
local DbTable = {}

---@private
---@param name string
---@param path Core.Path
---@param logger Core.Logger
function DbTable:__init(name, path, logger)
    self.name = name
    self.path = path
    self.logger = logger
    self.data = {}
end

function DbTable:Load()
    self.logger:LogTrace("loading Database Table: '".. self.name .."'...")
    local parentFolder = self.path:GetParentFolderPath()
    if not filesystem.exists(parentFolder:GetPath()) then
        filesystem.createDir(parentFolder:GetPath(), true)
    end

    if filesystem.exists(self.path:GetPath()) then
        local fileData = Utils.File.ReadAll(self.path:GetPath()) or ""
        local data = Json.decode(fileData)
        if type(data) == "table" then
            self.data = data
        end
    end
    self.logger:LogTrace("loaded Database Table")
end

function DbTable:Save()
    self.logger:LogTrace("saving Database Table: '" .. self.name .. "'...")
    Utils.File.Write(self.path:GetPath(), "w", Json.encode(self.data))
    self.logger:LogTrace("saved Database Table")
end

---@param key string | number
---@param value table
function DbTable:Set(key, value)
    self.data[key] = value
    self:Save()
end

---@param key string | number
function DbTable:Delete(key)
    self.data[key] = nil
    self:Save()
end

---@param key string | number
---@return table value
function DbTable:Get(key)
    return self.data[key]
end

---@private
---@return (fun(t: table, key: any) : key: any, value: any), table t, any startKey
function DbTable:__pairs()
    return next, self.data, nil
end

return Utils.Class.CreateClass(DbTable, "Database.DbTable")
]]
}

return PackageData
