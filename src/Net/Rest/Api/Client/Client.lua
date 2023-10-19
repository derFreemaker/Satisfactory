local EventNameUsage = require("Core.Usage_EventName")

local Response = require('Net.Rest.Api.Response')

---@class Net.Rest.Api.Client : object
---@field ServerIPAddress Net.Core.IPAddress
---@field ServerPort integer
---@field ReturnPort integer
---@field private _NetClient Net.Core.NetworkClient
---@field private _Logger Core.Logger
---@overload fun(serverIPAddress: Net.Core.IPAddress, serverPort: integer, returnPort: integer, netClient: Net.Core.NetworkClient, logger: Core.Logger) : Net.Rest.Api.Client
local Client = {}

---@private
---@param serverIPAddress Net.Core.IPAddress
---@param serverPort integer
---@param returnPort integer
---@param netClient Net.Core.NetworkClient
---@param logger Core.Logger
function Client:__init(serverIPAddress, serverPort, returnPort, netClient, logger)
	self.ServerIPAddress = serverIPAddress
	self.ServerPort = serverPort
	self.ReturnPort = returnPort
	self._NetClient = netClient
	self._Logger = logger
end

---@param request Net.Rest.Api.Request
---@param timeout integer?
---@return Net.Rest.Api.Response response
function Client:Send(request, timeout)
	self._NetClient:Send(self.ServerIPAddress, self.ServerPort, EventNameUsage.RestRequest, request:ExtractData(),
		{ ReturnPort = self.ReturnPort })
	local context = self._NetClient:WaitForEvent(EventNameUsage.RestResponse, self.ReturnPort, timeout or 5)
	if not context then
		return Response(nil, { Code = 408 })
	end

	local response = context:ToApiResponse()
	return response
end

return Utils.Class.CreateClass(Client, 'Net.Rest.Api.Client')
