local PackageData = {}

-- ########## Database ##########

PackageData.MFYoiWSx = {
    Namespace = "Database.DbTable",
    Name = "DbTable",
    FullName = "DbTable.lua",
    IsRunnable = true,
    Data = [[
local Json = require("Core.Json")
local DbTable = {}
function DbTable:__init(name, path, logger)
    self.name = name
    self.path = path
    self.logger = logger
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
    else
        self.data = {}
    end
    self.logger:LogTrace("loaded Database Table")
end
function DbTable:Save()
    self.logger:LogTrace("saving Database Table: '" .. self.name .. "'...")
    Utils.File.Write(self.path:GetPath(), "w", Json.encode(self.data))
    self.logger:LogTrace("saved Database Table")
end
function DbTable:Set(key, value)
    self.data[key] = value
    self:Save()
end
function DbTable:Delete(key)
    self.data[key] = nil
    self:Save()
end
function DbTable:Get(key)
    return self.data[key]
end
function DbTable:__pairs()
    return next, self.data, nil
end
return Utils.Class.CreateClass(DbTable, "DbTable")
]]
}

-- ########## Database ########## --

return PackageData
