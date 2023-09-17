---@namespace Net.Core.NetworkContext.Api.Extensions

local Request = require('Net.Rest.Api.Request')
local Response = require('Net.Rest.Api.Response')

---@class Net.Rest.Api.Extensions : object
local Extensions = {}

---@param context Net.Core.NetworkContext
---@return Net.Rest.Api.Request
function Extensions:Static_NetworkContextToApiRequest(context)
	return Request(context.Body.Method, context.Body.Endpoint, context.Body.Body, context.Body.Headers)
end

---@param context Net.Core.NetworkContext
---@return Net.Rest.Api.Response
function Extensions:Static_NetworkContextToApiResponse(context)
	return Response(context.Body.Body, context.Body.Headers)
end

return Utils.Class.CreateClass(Extensions, 'Net.Core.NetworkContext.Api.Extensions')
