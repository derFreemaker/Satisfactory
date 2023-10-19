---@meta
local PackageData = {}

PackageData["FactoryControlServer__main"] = {
    Location = "FactoryControl.Server.__main",
    Namespace = "FactoryControl.Server.__main",
    IsRunnable = true,
    Data = [[
local Config = require('FactoryControl.Core.Config')
local PortUsage = require('Core.Usage_Port')

local EventPullAdapter = require('Core.Event.EventPullAdapter')
local NetworkClient = require('Net.Core.NetworkClient')
local RestApiController = require('Net.Rest.Api.Server.Controller')

local Database = require("FactoryControl.Server.Database.Controllers")

local ControllerEndpoints = require('FactoryControl.Server.Endpoints.Controller')

local DNSClient = require('DNS.Client.Client')

---@class FactoryControl.Server.Main : Github_Loading.Entities.Main
---@field private _EventPullAdapter Core.EventPullAdapter
---@field private _ApiController Net.Rest.Api.Server.Controller
---@field private _DnsClient DNS.Client
---@field private _NetClient Net.Core.NetworkClient
local Main = {}

function Main:Configure()
	self._EventPullAdapter = EventPullAdapter:Initialize(self.Logger:subLogger('EventPullAdapter'))

	self._NetClient = NetworkClient(self.Logger:subLogger('NetworkClient'))
	local netPort = self._NetClient:CreateNetworkPort(PortUsage.HTTP)
	netPort:OpenPort()
	self._ApiController = RestApiController(netPort, self.Logger:subLogger('RestApiController'))

	local databaseAccessLayer = Database(self.Logger:subLogger("DatabaseAccessLayer"))

	self._ApiController:AddRestApiEndpointBase(
		ControllerEndpoints(self.Logger:subLogger("ControllerEndpoints"), databaseAccessLayer))

	self.Logger:LogDebug('setup endpoints')

	self._DnsClient = DNSClient(self._NetClient, self.Logger:subLogger('DNSClient'))
	self._DnsClient:CreateAddress(Config.DOMAIN, self._NetClient:GetIPAddress())
	self.Logger:LogDebug('registered dns client on server')
end

function Main:Run()
	self.Logger:LogInfo('started server')
	self._EventPullAdapter:Run()
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
    self._DbTable = DbTable("Controllers", Path("/Database/Controllers/"), logger:subLogger("DbTable"))
    self._Logger = logger

    self._DbTable:Load()
end

---@param createController FactoryControl.Core.Entities.Controller.CreateDto
---@return FactoryControl.Core.Entities.ControllerDto? controller
function Controllers:CreateController(createController)
    local controller = ControllerDto(UUID.Static__New(), createController.Name,
        createController.IPAddress, createController.Features)

    if self:GetControllerByName(createController.Name) then
        return nil
    end

    self._DbTable:Set(controller.Id, controller)
    self._DbTable:Save()

    return controller
end

---@param id Core.UUID
function Controllers:DeleteController(id)
    self._DbTable:Delete(id)
end

---@param id Core.UUID
---@return FactoryControl.Core.Entities.ControllerDto? controller
function Controllers:GetControllerById(id)
    return self._DbTable:Get(id)
end

---@param name string
---@return FactoryControl.Core.Entities.ControllerDto? controller
function Controllers:GetControllerByName(name)
    for key, controller in pairs(self._DbTable) do
        ---@cast key Core.UUID
        ---@cast controller FactoryControl.Core.Entities.ControllerDto

        if controller.Name == name then
            return controller
        end
    end
end

return Utils.Class.CreateClass(Controllers, "FactoryControl.Server.Database.Controllers")
]]
}

PackageData["FactoryControlServerEndpointsController"] = {
    Location = "FactoryControl.Server.Endpoints.Controller",
    Namespace = "FactoryControl.Server.Endpoints.Controller",
    IsRunnable = true,
    Data = [[
---@class FactoryControl.Server.Endpoints.ControllerEndpoints : Net.Rest.Api.Server.EndpointBase
---@field private _Controllers FactoryControl.Server.Database.Controllers
---@field private _Logger Core.Logger
---@overload fun(logger: Core.Logger, databaseAccessLayer: FactoryControl.Server.Database.Controllers) : FactoryControl.Server.Endpoints.ControllerEndpoints
local ControllerEndpoints = {}

---@private
---@param logger Core.Logger
---@param databaseAccessLayer FactoryControl.Server.Database.Controllers
function ControllerEndpoints:__init(logger, databaseAccessLayer)
	self._Controllers = databaseAccessLayer
	self._Logger = logger
end

---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function ControllerEndpoints:CONNECT__Controller(request)
	---@type string, Net.Core.IPAddress
	local name, ipAddress = request.Body[1], request.Body[2]

	local controller = self._Controllers:GetControllerByName(name)
	if not controller then
		return self.Templates:NotFound("Controller with Name: " .. name .. " was not found.")
	end

	controller.IPAddress = ipAddress

	return self.Templates:Ok(controller)
end

---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function ControllerEndpoints:CREATE__Controller(request)
	---@type FactoryControl.Core.Entities.Controller.CreateDto
	local createController = request.Body

	local controller = self._Controllers:CreateController(createController)

	if not controller then
		return self.Templates:BadRequest("Controller with Name: " .. createController.Name .. " already exists.")
	end

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
function ControllerEndpoints:POST__ModifyControllerById(request)
	---@type Core.UUID, FactoryControl.Core.Entities.Controller.ModifyDto
	local id, modifyController = request.Body[1], request.Body[2]

	local controller = self._Controllers:GetControllerById(id)

	if not controller then
		return self.Templates:NotFound("Controller with id: " .. tostring(id) .. " was not found.")
	end

	controller.Features = modifyController.Features

	return self.Templates:Ok(controller)
end

---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function ControllerEndpoints:GET__ControllerById(request)
	---@type Core.UUID
	local id = request.Body

	local controller = self._Controllers:GetControllerById(id)

	if not controller then
		return self.Templates:NotFound("Controller with id: " .. tostring(id))
	end

	return self.Templates:Ok(controller)
end

---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function ControllerEndpoints:GET__ControllerByName(request)
	---@type string
	local name = request.Body

	local controller = self._Controllers:GetControllerByName(name)

	if not controller then
		return self.Templates:NotFound("Controller with id: " .. name)
	end

	return self.Templates:Ok(controller)
end

return Utils.Class.CreateClass(ControllerEndpoints, 'FactoryControl.Server.ControllerEndpoints',
	require('Net.Rest.Api.Server.EndpointBase'))
]]
}

return PackageData
