---@meta
local PackageData = {}

PackageData["FactoryControlServer__main"] = {
    Location = "FactoryControl.Server.__main",
    Namespace = "FactoryControl.Server.__main",
    IsRunnable = true,
    Data = [[
local Config = require('FactoryControl.Core.Config')
local PortUsage = require('Core.Usage.Usage_Port')

local EventPullAdapter = require('Core.Event.EventPullAdapter')
local NetworkClient = require('Net.Core.NetworkClient')
local RestApiController = require('Net.Rest.Api.Server.Controller')

local Database = require("FactoryControl.Server.Database.Controllers")

local ControllerEndpoints = require('FactoryControl.Server.Endpoints.Controller')

local DNSClient = require('DNS.Client.Client')

local Host = require('Hosting.Host')

---@class FactoryControl.Server.Main : Github_Loading.Entities.Main
---@field private _Host Hosting.Host
---@field private _EventPullAdapter Core.EventPullAdapter
---@field private _ApiController Net.Rest.Api.Server.Controller
---@field private _DnsClient DNS.Client
---@field private _NetClient Net.Core.NetworkClient
local Main = {}

function Main:Configure()
	self._Host = Host(self.Logger:subLogger('Host'))

	local databaseAccessLayer = Database(self.Logger:subLogger("DatabaseAccessLayer"))

	self._Host:AddEndpoint(PortUsage.HTTP,
		"Controller",
		ControllerEndpoints --{{{@as FactoryControl.Server.Endpoints.ControllerEndpoints}}},
		databaseAccessLayer)
	self.Logger:LogDebug('setup endpoints')

	self._Host:RegisterAddress(Config.DOMAIN)
end

function Main:Run()
	self.Logger:LogInfo('started server')
	self._Host:Run()
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
---@overload fun(logger: Core.Logger, apiController: Net.Rest.Api.Server.Controller, databaseAccessLayer: FactoryControl.Server.Database.Controllers) : FactoryControl.Server.Endpoints.ControllerEndpoints
local ControllerEndpoints = {}

---@private
---@param logger Core.Logger
---@param apiController Net.Rest.Api.Server.Controller
---@param databaseAccessLayer FactoryControl.Server.Database.Controllers
---@param baseFunc fun(endpointLogger: Core.Logger, apiController: Net.Rest.Api.Server.Controller)
function ControllerEndpoints:__init(baseFunc, logger, apiController, databaseAccessLayer)
	baseFunc(logger, apiController)

	self._Controllers = databaseAccessLayer

	self:AddEndpoint("CONNECT", "/Controller/Connect", self.Connect)

	self:AddEndpoint("CREATE", "/Controller/Create", self.Create)
	self:AddEndpoint("DELETE", "/Controller/{id:Core.UUID}/Delete", self.DeleteWithId)
	self:AddEndpoint("POST", "/Controller/{id:Core.UUID}/Modify", self.ModifyWithId)
	self:AddEndpoint("GET", "/Controller/{id:Core.UUID}", self.GetWithId)
	self:AddEndpoint("GET", "/Controller/GetWithName", self.GetWithName)
end

---@param connect FactoryControl.Core.Entities.Controller.ConnectDto
---@return Net.Rest.Api.Response response
function ControllerEndpoints:Connect(connect)
	local controller = self._Controllers:GetControllerByName(connect.Name)
	if not controller then
		return self.Templates:NotFound("Controller with Name: " .. connect.Name .. " was not found.")
	end

	if controller.IPAddress ~= connect.IPAddress then
		controller.IPAddress = connect.IPAddress
	end

	return self.Templates:Ok(controller)
end

---@param createController FactoryControl.Core.Entities.Controller.CreateDto
---@return Net.Rest.Api.Response response
function ControllerEndpoints:Create(createController)
	local controller = self._Controllers:CreateController(createController)

	if not controller then
		return self.Templates:BadRequest("Controller with Name: " .. createController.Name .. " already exists.")
	end

	return self.Templates:Ok(controller)
end

---@param id Core.UUID
---@return Net.Rest.Api.Response response
function ControllerEndpoints:DeleteWithId(id)
	self._Controllers:DeleteController(id)

	return self.Templates:Ok(true)
end

---@param id Core.UUID
---@param modifyController FactoryControl.Core.Entities.Controller.ModifyDto
---@return Net.Rest.Api.Response response
function ControllerEndpoints:ModifyWithId(id, modifyController)
	local controller = self._Controllers:GetControllerById(id)

	if not controller then
		return self.Templates:NotFound("Controller with id: " .. tostring(id) .. " was not found.")
	end

	controller.Features = modifyController.Features

	return self.Templates:Ok(controller)
end

---@param id Core.UUID
---@return Net.Rest.Api.Response response
function ControllerEndpoints:GetWithId(id)
	local controller = self._Controllers:GetControllerById(id)

	if not controller then
		return self.Templates:NotFound("Controller with id: " .. tostring(id) .. " was not found.")
	end

	return self.Templates:Ok(controller)
end

---@param name string
---@return Net.Rest.Api.Response response
function ControllerEndpoints:GetWithName(name)
	local controller = self._Controllers:GetControllerByName(name)

	if not controller then
		return self.Templates:NotFound("Controller with name: " .. name .. " was not found.")
	end

	return self.Templates:Ok(controller)
end

return Utils.Class.CreateClass(ControllerEndpoints, 'FactoryControl.Server.ControllerEndpoints',
	require('Net.Rest.Api.Server.EndpointBase') --{{{@as Net.Rest.Api.Server.EndpointBase}}})
]]
}

return PackageData
