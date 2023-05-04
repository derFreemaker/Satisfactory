local Utils = require("src (Outdated).Core.shared.Utils.Index")
local Serializer = require("libs.Serializer")

---@class DatabaseAccessLayer
---@field private logger Logger
---@field Controllers ControllerData[]
local DatabaseAccessLayer = {}
DatabaseAccessLayer.__index = DatabaseAccessLayer

local controllerFilePath = filesystem.path("Database", "Controllers.db")

---@param logger Logger
---@return DatabaseAccessLayer
function DatabaseAccessLayer:Initialize(logger)
    self.logger = logger:create("DatabaseAccessLayer")
    return self
end

function DatabaseAccessLayer:load()
    self.logger:LogTrace("loading Database...")
    if not filesystem.exists("Database") then
        filesystem.createDir("Database")
    end

    if filesystem.exists("Database/Controllers.db") then
        local controllerFile = filesystem.open("Database/Controllers.db", "r")
        self.Controllers = Serializer:Deserialize(controllerFile:read("*all"))
        controllerFile:close()
    else
        self.Controllers = {}
    end
    self.logger:LogDebug("loaded Database")
end

function DatabaseAccessLayer:saveChanges()
    self.logger:LogTrace("saving Database...")
    Utils.File.Write(controllerFilePath, "w", Serializer:Serialize(self.Controllers))
    self.logger:LogDebug("saved Database")
end
-- Core

-- Controller
---@param controllerData ControllerData
---@return ControllerData
function DatabaseAccessLayer:CreateController(controllerData)
    table.insert(self.Controllers, controllerData)
    self:saveChanges()
    return controllerData
end

---@param controllerIpAddress string
---@return boolean
function DatabaseAccessLayer:DeleteController(controllerIpAddress)
    for i, controller in pairs(self.Controllers) do
        if controller.IPAddress == controllerIpAddress then
            table.remove(self.Controllers, i)
        end
    end
    self:saveChanges()
    return true
end

---@param controllerIpAddress string
---@return ControllerData | nil
function DatabaseAccessLayer:GetController(controllerIpAddress)
    for _, controller in pairs(self.Controllers) do
        if controller.IPAddress == controllerIpAddress then
            return controller
        end
    end
    return nil
end

---@return ControllerData[]
function DatabaseAccessLayer:GetControllers()
    return self.Controllers
end

---@return ControllerData[]
function DatabaseAccessLayer:GetControllersFromCategory(category)
    local controllers = {}
    for _, controller in pairs(self.Controllers) do
        if controller.Category == category then
            table.insert(controllers, controller)
        end
    end
    return controllers
end
-- Controller

return DatabaseAccessLayer