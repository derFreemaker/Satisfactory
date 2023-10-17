local NetworkContext = require("Net.Core.NetworkContext")
local Request = require('Net.Rest.Api.Request')
local Response = require('Net.Rest.Api.Response')

---@class Net.Core.NetworkContext
local NetworkContextExtensions = {}

--- ## Extension from Net.Rest
---@return Net.Rest.Api.Request
function NetworkContextExtensions:ToApiRequest()
	return Request(self.Body.Method, self.Body.Endpoint, self.Body.Body, self.Body.Headers)
end

--- ## Extension from Net.Rest
---@return Net.Rest.Api.Response
function NetworkContextExtensions:ToApiResponse()
	return Response(self.Body.Body, self.Body.Headers)
end

Utils.Class.ExtendClass(NetworkContextExtensions, NetworkContext --[[@as Net.Core.NetworkContext]])
