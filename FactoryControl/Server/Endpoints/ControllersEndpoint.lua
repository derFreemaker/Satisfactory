local DatabaseAccessLayer = require("FactoryControl.Server.src.Data.DatabaseAccessLayer")
local ApiController = require("libs.Api.ApiController")
local Listener = require("libs.Listener")

---@class ControllersEndpoint
---@field private databaseAccessLayer DatabaseAccessLayer
---@field private apiController ApiController
---@---@field private logger Logger
local ControllersEndpoint = {}
ControllersEndpoint.__index = ControllersEndpoint

---@param netPort NetworkPort
---@param logger Logger
function ControllersEndpoint:Configure(netPort, logger)
    self.logger = logger:create("ControllersEndpoint")
    self.databaseAccessLayer = DatabaseAccessLayer
    self.apiController = ApiController.new(netPort)
        :AddEndpoint("CreateController", Listener.new(self.CreateController, self))
        :AddEndpoint("DeleteController", Listener.new(self.DeleteController, self))
        :AddEndpoint("GetController", Listener.new(self.GetController, self))
        :AddEndpoint("GetControllers", Listener.new(self.GetControllers, self))
        :AddEndpoint("GetControllersFromCategory", Listener.new(self.GetControllersFromCategory, self))
end

---@param context NetworkContext
---@return ControllerData
function ControllersEndpoint:CreateController(context)
    return self.databaseAccessLayer:CreateController(context.Body.ControllerData)
end

---@param context NetworkContext
---@return boolean
function ControllersEndpoint:DeleteController(context)
    return self.databaseAccessLayer:DeleteController(context.Body.ControllerIPAddress)
end

---@param context NetworkContext
---@return ControllerData | nil
function ControllersEndpoint:GetController(context)
    return self.databaseAccessLayer:GetController(context.Body.ControllerIPAddress)
end

---@param context NetworkContext
---@return ControllerData[]
function ControllersEndpoint:GetControllers(context)
    return self.databaseAccessLayer:GetControllers()
end

---@param context NetworkContext
---@return ControllerData[]
function ControllersEndpoint:GetControllersFromCategory(context)
    return self.databaseAccessLayer:GetControllersFromCategory(context.Body.Category)
end

return ControllersEndpoint