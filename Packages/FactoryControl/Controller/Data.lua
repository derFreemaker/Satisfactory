---@meta
local PackageData = {}

PackageData["FactoryControlController__main"] = {
    Location = "FactoryControl.Controller.__main",
    Namespace = "FactoryControl.Controller.__main",
    IsRunnable = true,
    Data = [[
local NetworkClient = require('Net.Core.NetworkClient')
local FactoryControlRestApiClient = require('FactoryControl.Controller.FactoryControlApiClient')
local EventPullAdapter = require('Core.Event.EventPullAdapter')

---@class FactoryControl.Controller.Main : Github_Loading.Entities.Main
---@field private apiClient FactoryControl.Controller.Client
local Main = {}

function Main:Configure()
	EventPullAdapter:Initialize(self.Logger:subLogger('EventPullAdapter'))

	local netClient = NetworkClient(self.Logger:subLogger('NetworkClient'))
	self.apiClient = FactoryControlRestApiClient(netClient, self.Logger:subLogger('ApiClient'))
	self.Logger:LogDebug('setup apiClient')
end

function Main:Run()
	local result = self.apiClient:CreateController()
	self.Logger:LogInfo('result: ' .. tostring(result))
end

return Main
]]
}

PackageData["FactoryControlControllerFactoryControlApiClient"] = {
    Location = "FactoryControl.Controller.FactoryControlApiClient",
    Namespace = "FactoryControl.Controller.FactoryControlApiClient",
    IsRunnable = true,
    Data = [[
local ApiClient = require('Net.Rest.Api.Client.Client')
local HttpRequest = require('Net.Rest.Api.Request')

---@class FactoryControl.Controller.Client : object
---@field private restApiClient Net.Rest.Api.Client
---@field private logger Core.Logger
---@overload fun(netClient: Net.Core.NetworkClient, logger: Core.Logger) : FactoryControl.Controller.Client
local FactoryControlRestApiClient = {}

---@private
---@param netClient Net.Core.NetworkClient
---@param logger Core.Logger
function FactoryControlRestApiClient:__init(netClient, logger)
	self.restApiClient = ApiClient(Config.ServerIPAddress, Config.ServerPort, 1111, netClient, self.logger:subLogger('RestApiClient'))
end

---@private
---@param method Net.Core.Method
---@param endpoint string
---@param headers Dictionary<string, any>?
---@param body any
---@return Net.Rest.Api.Response response
function FactoryControlRestApiClient:request(method, endpoint, headers, body)
	return self.restApiClient:Send(HttpRequest(method, endpoint, headers, body))
end

---@return boolean
function FactoryControlRestApiClient:CreateController()
	local response = self:request('CREATE', 'Controller')
	return response.Body
end

return Utils.Class.CreateClass(FactoryControlRestApiClient, 'FactoryControl.Controller.Client')
]]
}

return PackageData
