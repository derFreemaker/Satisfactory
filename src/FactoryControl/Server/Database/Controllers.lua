local DbTable = require("Database.DbTable")
local Path = require("Core.FileSystem.Path")
local UUID = require("Core.UUID")

local ControllerDto = require("FactoryControl.Core.Entities.Controller.ControllerDto")

---@class FactoryControl.Server.Database.Controllers : object
---@field private m_dbTable Database.DbTable
---@field private m_logger Core.Logger
---@overload fun(logger: Core.Logger) : FactoryControl.Server.Database.Controllers
local Controllers = {}

---@private
---@param logger Core.Logger
function Controllers:__init(logger)
    self.m_dbTable = DbTable("Controllers", Path("/Database/Controllers/"), logger:subLogger("DbTable"))
    self.m_logger = logger

    self.m_dbTable:Load()
end

---@param createController FactoryControl.Core.Entities.Controller.CreateDto
---@return FactoryControl.Core.Entities.ControllerDto? controller
function Controllers:CreateController(createController)
    local controller = ControllerDto(UUID.Static__New(), createController.Name,
        createController.IPAddress, createController.Features)

    if self:GetControllerByName(createController.Name) then
        return nil
    end

    self.m_dbTable:Set(controller.Id, controller)
    self.m_dbTable:Save()

    return controller
end

---@param id Core.UUID
function Controllers:DeleteController(id)
    self.m_dbTable:Delete(id)
end

---@param id Core.UUID
---@return FactoryControl.Core.Entities.ControllerDto? controller
function Controllers:GetControllerById(id)
    return self.m_dbTable:Get(id)
end

---@param name string
---@return FactoryControl.Core.Entities.ControllerDto? controller
function Controllers:GetControllerByName(name)
    for key, controller in pairs(self.m_dbTable) do
        ---@cast key Core.UUID
        ---@cast controller FactoryControl.Core.Entities.ControllerDto

        if controller.Name == name then
            return controller
        end
    end
end

return Utils.Class.CreateClass(Controllers, "FactoryControl.Server.Database.Controllers")
