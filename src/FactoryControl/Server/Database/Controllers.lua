local DbTable = require("Database.DbTable")
local Path = require("Core.FileSystem.Path")
local UUID = require("Core.UUID")

local ControllerDto = require("FactoryControl.Core.Entities.Controller.ControllerDto")

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

---@param createController FactoryControl.Core.Entities.Controller.CreateDto
---@return FactoryControl.Core.Entities.Controller.ControllerDto controller
function Controllers:CreateController(createController)
    local controller = ControllerDto(UUID.Static__New(), createController.IPAddress, createController.Features)

    self._DbTable:Set(controller.Id, controller)
    self._DbTable:Save()

    return controller
end

---@param id Core.UUID
function Controllers:DeleteController(id)
    self._DbTable:Delete(id)
end

---@param id Core.UUID
---@return FactoryControl.Core.Entities.Controller.ControllerDto? controller
function Controllers:GetController(id)
    return self._DbTable:Get(id)
end

return Utils.Class.CreateClass(Controllers, "FactoryControl.Server.Database.Controllers")
