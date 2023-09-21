local Response = require('Net.Rest.Api.Response')
---@type Net.Rest.Api.Extensions
local Extensions = require('Net.Core.NetworkContext.Api.Extensions')

---@class Net.Rest.Api.Client : object
---@field ServerIPAddress string
---@field ServerPort integer
---@field ReturnPort integer
---@field private NetClient Net.Core.NetworkClient
---@field private logger Core.Logger
---@overload fun(serverIPAddress: string, serverPort: integer, returnPort: integer, netClient: Net.Core.NetworkClient, logger: Core.Logger) : Net.Rest.Api.Client
local Client = {}

---@private
---@param serverIPAddress string
---@param serverPort integer
---@param returnPort integer
---@param netClient Net.Core.NetworkClient
---@param logger Core.Logger
function Client:__init(serverIPAddress, serverPort, returnPort, netClient, logger)
	self.ServerIPAddress = serverIPAddress
	self.ServerPort = serverPort
	self.ReturnPort = returnPort
	self.NetClient = netClient
	self.logger = logger
end

---@param request Net.Rest.Api.Request
---@param timeout integer?
---@return Net.Rest.Api.Response response
function Client:Send(request, timeout)
	self.NetClient:Send(self.ServerIPAddress, self.ServerPort, 'Rest-Request', request:ExtractData(), {ReturnPort = self.ReturnPort})
	local context = self.NetClient:WaitForEvent('Rest-Response', self.ReturnPort, timeout or 5)
	if not context then
		return Response(nil, {Code = 408})
	end

	local response = Extensions:Static_NetworkContextToApiResponse(context)
	return response
end

return Utils.Class.CreateClass(Client, 'Net.Rest.Api.Client')
