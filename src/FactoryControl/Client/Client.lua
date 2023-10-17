local ApiClient = require('Net.Rest.Api.Client.Client')
local ApiRequest = require('Net.Rest.Api.Request')

---@class FactoryControl.Controller.Client : object
---@field private restApiClient Net.Rest.Api.Client
---@field private logger Core.Logger
---@overload fun(netClient: Net.Core.NetworkClient, logger: Core.Logger) : FactoryControl.Controller.Client
local FactoryControlRestApiClient = {}

---@private
---@param netClient Net.Core.NetworkClient
---@param logger Core.Logger
function FactoryControlRestApiClient:__init(netClient, logger)
	self.restApiClient = ApiClient(Config.ServerIPAddress, Config.ServerPort, 1111, netClient,
		self.logger:subLogger('RestApiClient'))
end

---@private
---@param method Net.Core.Method
---@param endpoint string
---@param body any
---@param headers Dictionary<string, any>?
---@return Net.Rest.Api.Response response
function FactoryControlRestApiClient:request(method, endpoint, body, headers)
	return self.restApiClient:Send(ApiRequest(method, endpoint, body, headers))
end

---@param createController FactoryControl.Core.Entities.Controller.CreateDto
---@return FactoryControl.Core.Entities.Controller.ControllerDto
function FactoryControlRestApiClient:CreateController(createController)
	local response = self:request('CREATE', 'Controller', createController)
	return response.Body
end

return Utils.Class.CreateClass(FactoryControlRestApiClient, 'FactoryControl.Controller.Client')
