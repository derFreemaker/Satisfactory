local DatabaseAccessLayer = ModuleLoader.PreLoadModule("DatabaseAccessLayer")
local ApiController = ModuleLoader.PreLoadModule("ApiController")

local ControllersEndpoint = {}
ControllersEndpoint.__index = ControllersEndpoint

ControllersEndpoint._logger = {}
ControllersEndpoint.DatabaseAccessLayer = {}
ControllersEndpoint.NetClient = {}

function ControllersEndpoint:Configure(netPort, logger)
    self._logger = logger:create("ControllersEndpoint")
    self.DatabaseAccessLayer = DatabaseAccessLayer
    self.ApiController = ApiController.new(netPort)
        :AddEndpoint("CreateController", {Func=self.CreateController, Object=self})
        :AddEndpoint("DeleteController", {Func=self.DeleteController, Object=self})
        :AddEndpoint("GetController", {Func=self.GetController, Object=self})
        :AddEndpoint("GetControllers", {Func=self.GetControllers, Object=self})
        :AddEndpoint("GetControllersFromCategory", {Func=self.GetControllersFromCategory, Object=self})
end

function ControllersEndpoint:CreateController(context)
    return self.DatabaseAccessLayer:CreateController(context.Body.ControllerData)
end

function ControllersEndpoint:DeleteController(context)
    return self.DatabaseAccessLayer:DeleteController(context.Body.ControllerIPAddress)
end

function ControllersEndpoint:GetController(context)
    return self.DatabaseAccessLayer:GetController(context.Body.ControllerIPAddress)
end

function ControllersEndpoint:GetControllers(context)
    return self.DatabaseAccessLayer:GetControllers()
end

function ControllersEndpoint:GetControllersFromCategory(context)
    return self.DatabaseAccessLayer:GetControllersFromCategory(context.Body.Category)
end

return ControllersEndpoint