---@meta
local PackageData = {}

PackageData["FactoryControlServer__main"] = {
    Location = "FactoryControl.Server.__main",
    Namespace = "FactoryControl.Server.__main",
    IsRunnable = true,
    Data = [[
local Config = require('FactoryControl.Core.Config')
local PortUsage = require('Core.PortUsage')

local EventPullAdapter = require('Core.Event.EventPullAdapter')
local NetworkClient = require('Net.Core.NetworkClient')
local RestApiController = require('Net.Rest.Api.Server.Controller')
local ControllerEndpoints = require('FactoryControl.Server.Endpoints.ControllerEndpoints')
local DNSClient = require('DNS.Client.Client')

---@class FactoryControl.Server.Main : Github_Loading.Entities.Main
---@field private eventPullAdapter Core.EventPullAdapter
---@field private apiController Net.Rest.Api.Server.Controller
---@field private dnsClient DNS.Client
---@field private netClient Net.Core.NetworkClient
local Main = {}

function Main:Configure()
	self.eventPullAdapter = EventPullAdapter:Initialize(self.Logger:subLogger('EventPullAdapter'))

	self.netClient = NetworkClient(self.Logger:subLogger('NetworkClient'))
	local netPort = self.netClient:CreateNetworkPort(PortUsage.HTTP)
	netPort:OpenPort()
	self.apiController = RestApiController(netPort, self.Logger:subLogger('RestApiController'))
	self.apiController:AddRestApiEndpointBase(ControllerEndpoints(self.Logger:subLogger("ControllerEndpoints")))
	self.Logger:LogDebug('setup endpoints')

	self.dnsClient = DNSClient(self.netClient, self.Logger:subLogger('DNSClient'))
	self.dnsClient:CreateAddress(Config.DOMAIN, self.netClient:GetId())
	self.Logger:LogDebug('registered dns client on server')
end

function Main:Run()
	self.Logger:LogInfo('started server')
	self.eventPullAdapter:Run()
end

return Main
]]
}

PackageData["FactoryControlServerDatabaseControllers"] = {
    Location = "FactoryControl.Server.Database.Controllers",
    Namespace = "FactoryControl.Server.Database.Controllers",
    IsRunnable = true,
    Data = [[
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
]]
}

PackageData["FactoryControlServerEndpointsControllerEndpoints"] = {
    Location = "FactoryControl.Server.Endpoints.ControllerEndpoints",
    Namespace = "FactoryControl.Server.Endpoints.ControllerEndpoints",
    IsRunnable = true,
    Data = [[
local Controllers = require("FactoryControl.Server.Database.Controllers")

---@class FactoryControl.Server.Endpoints.ControllerEndpoints : Net.Rest.Api.Server.EndpointBase
---@field private _Controllers FactoryControl.Server.Database.Controllers
---@field private _Logger Core.Logger
---@overload fun(logger: Core.Logger) : FactoryControl.Server.Endpoints.ControllerEndpoints
local ControllerEndpoints = {}

---@private
---@param logger Core.Logger
function ControllerEndpoints:__init(logger)
	self._Controllers = Controllers(logger:subLogger("Database"))
	self._Logger = logger
end

---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function ControllerEndpoints:CREATE__Controller(request)
	---@type FactoryControl.Core.Entities.Controller.CreateDto
	local createController = request.Body

	local controller = self._Controllers:CreateController(createController)

	return self.Templates:Ok(controller)
end

---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function ControllerEndpoints:DELETE__ControllerById(request)
	---@type Core.UUID
	local id = request.Body

	self._Controllers:DeleteController(id)

	return self.Templates:Ok()
end

---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function ControllerEndpoints:GET__ControllerById(request)
	---@type Core.UUID
	local id = request.Body

	local controller = self._Controllers:GetController(id)

	if not controller then
		return self.Templates:NotFound("Controller with id: " .. tostring(id))
	end

	return self.Templates:Ok(controller)
end

-- get controller with name

return Utils.Class.CreateClass(ControllerEndpoints, 'FactoryControl.Server.ControllerEndpoints',
	require('Net.Rest.Api.Server.EndpointBase'))
]]
}

return PackageData
