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
		ControllerEndpoints --[[@as FactoryControl.Server.Endpoints.ControllerEndpoints]],
		databaseAccessLayer)
	self.Logger:LogDebug('setup endpoints')

	self._Host:RegisterAddress(Config.DOMAIN)
end

function Main:Run()
	self.Logger:LogInfo('started server')
	self._Host:Run()
end

return Main
