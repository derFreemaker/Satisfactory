local DbTable = require("Database.DbTable")
local Path = require("Core.Path")

---@class FactoryControl.Server.Database.Controllers : object
---@field private _DbTable Database.DbTable
---@field private _Logger Core.Logger
---@overload fun(logger: Core.Logger) : FactoryControl.Server.Database.Controllers
local Controllers = {}

---@private
---@param logger Core.Logger
function Controllers:__init(logger)
    self._DbTable = DbTable("Controllers", Path("/Database/Controllers"), logger:subLogger("DbTable"))
    self._Logger = logger

    self._DbTable:Load()
end

return Utils.Class.CreateClass(Controllers, "FactoryControl.Server.Database.Controllers")
