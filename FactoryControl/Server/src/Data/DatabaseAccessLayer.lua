local Serializer = ModuleLoader.PreLoadModule("Serializer")

local DatabaseAccessLayer = {}
DatabaseAccessLayer.__index = DatabaseAccessLayer

function DatabaseAccessLayer:Initialize(logger)
    self._logger = logger:create("DatabaseAccessLayer")
    return self
end

function DatabaseAccessLayer:load()
    self._logger:LogDebug("loading Database...")
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
    self._logger:LogDebug("loaded Database")
end

function DatabaseAccessLayer:saveChanges()
    self._logger:LogDebug("saving Database...")
    local controllerFile = filesystem.open("Database/Controllers.db", "w")
    controllerFile:write(Serializer:Serialize(self.Controllers))
    controllerFile:close()
    self._logger:LogDebug("saved Database")
end
-- Core

-- Controller
function DatabaseAccessLayer:AddController(controllerData)
    table.insert(self.Controllers, controllerData)
    self:saveChanges()
    return true
end

function DatabaseAccessLayer:DeleteController(controllerIpAddress)
    for i, controller in pairs(self.Controllers) do
        if controller.IPAddress == controllerIpAddress then
            table.remove(self.Controllers, i)
        end
    end
    self:saveChanges()
    return true
end

function DatabaseAccessLayer:GetController(controllerIpAddress)
    for _, controller in pairs(self.Controllers) do
        if controller.IPAddress == controllerIpAddress then
            return controller
        end
    end
end

function DatabaseAccessLayer:GetControllers()
    return self.Controllers
end

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