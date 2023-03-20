local DatabaseAccessLayer = require("FactoryControl.Server.Data.DAL")
local ApiController = require("libs.Api.ApiController")
local Listener = require("libs.Listener")

local ControllersEndpoint = {}
ControllersEndpoint.__index = ControllersEndpoint

ControllersEndpoint._logger = {}
ControllersEndpoint.DatabaseAccessLayer = {}
ControllersEndpoint.NetClient = {}

function ControllersEndpoint:Configure(netPort, logger)
    self._logger = logger:create("ControllersEndpoint")
    self.DatabaseAccessLayer = DatabaseAccessLayer
    self.ApiController = ApiController.new(netPort)
        :AddEndpoint("CreateController", Listener.new(self.CreateController, self))
        :AddEndpoint("DeleteController", Listener.new(self.DeleteController, self))
        :AddEndpoint("GetController", Listener.new(self.GetController, self))
        :AddEndpoint("GetControllers", Listener.new(self.GetControllers, self))
        :AddEndpoint("GetControllersFromCategory", Listener.new(self.GetControllersFromCategory, self))
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