---@meta
local PackageData = {}

PackageData["FactoryControlServer__events"] = {
    Location = "FactoryControl.Server.__events",
    Namespace = "FactoryControl.Server.__events",
    IsRunnable = true,
    Data = [[
local DNSClient = require('DNS.Client.Client')

---@class FactoryControl.Server.Events : Github_Loading.Entities.Events
local Events = {}

return Events
]]
}

PackageData["FactoryControlServer__main"] = {
    Location = "FactoryControl.Server.__main",
    Namespace = "FactoryControl.Server.__main",
    IsRunnable = true,
    Data = [[
local Config = require('FactoryControl.Core.Config')
local PortUsage = require('Core.Usage.Usage_Port')

local Database = require("FactoryControl.Server.Database.Controllers")

local ControllerEndpoints = require('FactoryControl.Server.Endpoints.Controller')

local Host = require('Hosting.Host')

---@class FactoryControl.Server.Main : Github_Loading.Entities.Main
---@field private m_host Hosting.Host
---@field private m_eventPullAdapter Core.EventPullAdapter
---@field private m_apiController Net.Rest.Api.Server.Controller
---@field private m_dnsClient DNS.Client
---@field private m_netClient Net.Core.NetworkClient
local Main = {}

function Main:Configure()
	self.m_host = Host(self.Logger:subLogger('Host'), "FactoryControl Server")

	local databaseAccessLayer = Database(self.Logger:subLogger("DatabaseAccessLayer"))

	self.m_host:AddEndpoint(PortUsage.HTTP,
		"Controller",
		ControllerEndpoints --{{{@as FactoryControl.Server.Endpoints.ControllerEndpoints}}},
		databaseAccessLayer)
	self.Logger:LogDebug('setup endpoints')

	self.m_host:RegisterAddress(Config.DOMAIN)
end

function Main:Run()
	self.m_host:Run()
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
]]
}

PackageData["FactoryControlServerEndpointsController"] = {
    Location = "FactoryControl.Server.Endpoints.Controller",
    Namespace = "FactoryControl.Server.Endpoints.Controller",
    IsRunnable = true,
    Data = [[
---@class FactoryControl.Server.Endpoints.ControllerEndpoints : Net.Rest.Api.Server.EndpointBase
---@field private m_controllers FactoryControl.Server.Database.Controllers
---@field private m_logger Core.Logger
---@overload fun(logger: Core.Logger, apiController: Net.Rest.Api.Server.Controller, databaseAccessLayer: FactoryControl.Server.Database.Controllers) : FactoryControl.Server.Endpoints.ControllerEndpoints
local ControllerEndpoints = {}

---@private
---@param logger Core.Logger
---@param apiController Net.Rest.Api.Server.Controller
---@param databaseAccessLayer FactoryControl.Server.Database.Controllers
---@param baseFunc fun(endpointLogger: Core.Logger, apiController: Net.Rest.Api.Server.Controller)
function ControllerEndpoints:__init(baseFunc, logger, apiController, databaseAccessLayer)
	baseFunc(logger, apiController)

	self.m_controllers = databaseAccessLayer

	self:AddEndpoint("CONNECT", "/Controller/Connect", self.Connect)

	self:AddEndpoint("CREATE", "/Controller/Create", self.Create)
	self:AddEndpoint("DELETE", "/Controller/{id:Core.UUID}/Delete", self.DeleteWithId)
	self:AddEndpoint("POST", "/Controller/{id:Core.UUID}/Modify", self.ModifyWithId)
	self:AddEndpoint("GET", "/Controller/{id:Core.UUID}", self.GetWithId)
	self:AddEndpoint("GET", "/Controller/GetWithName/{name:string}", self.GetWithName)
end

---@param connect FactoryControl.Core.Entities.Controller.ConnectDto
---@return Net.Rest.Api.Response response
function ControllerEndpoints:Connect(connect)
	local controller = self.m_controllers:GetControllerByName(connect.Name)
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
	local controller = self.m_controllers:CreateController(createController)

	if not controller then
		return self.Templates:BadRequest("Controller with Name: " .. createController.Name .. " already exists.")
	end

	return self.Templates:Ok(controller)
end

---@param id Core.UUID
---@return Net.Rest.Api.Response response
function ControllerEndpoints:DeleteWithId(id)
	self.m_controllers:DeleteController(id)

	return self.Templates:Ok(true)
end

---@param id Core.UUID
---@param modifyController FactoryControl.Core.Entities.Controller.ModifyDto
---@return Net.Rest.Api.Response response
function ControllerEndpoints:ModifyWithId(id, modifyController)
	local controller = self.m_controllers:GetControllerById(id)

	if not controller then
		return self.Templates:NotFound("Controller with id: " .. tostring(id) .. " was not found.")
	end

	controller.Features = modifyController.Features

	return self.Templates:Ok(controller)
end

---@param id Core.UUID
---@return Net.Rest.Api.Response response
function ControllerEndpoints:GetWithId(id)
	local controller = self.m_controllers:GetControllerById(id)

	if not controller then
		return self.Templates:NotFound("Controller with id: " .. tostring(id) .. " was not found.")
	end

	return self.Templates:Ok(controller)
end

---@param name string
---@return Net.Rest.Api.Response response
function ControllerEndpoints:GetWithName(name)
	local controller = self.m_controllers:GetControllerByName(name)

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
