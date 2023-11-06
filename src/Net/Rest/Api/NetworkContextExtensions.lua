local NetworkContext = require("Net.Core.NetworkContext")

---@class Net.Core.NetworkContext
local NetworkContextExtensions = {}

--- ## Extension from Net.Rest
---@return Net.Rest.Api.Request
function NetworkContextExtensions:GetApiRequest()
	return self.Body
end

--- ## Extension from Net.Rest
---@return Net.Rest.Api.Response
function NetworkContextExtensions:GetApiResponse()
	return self.Body
end

Utils.Class.ExtendClass(NetworkContextExtensions, NetworkContext)
