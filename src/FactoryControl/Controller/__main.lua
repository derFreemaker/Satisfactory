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
