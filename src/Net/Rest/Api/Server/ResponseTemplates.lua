local StatusCodes = require("Net.Core.StatusCodes")
local Response = require("Net.Rest.Api.Core.Response")

---@class Net.Rest.Api.Server.RestApiResponseTemplates
local ResponseTemplates = {}

---@param value any
---@return Net.Rest.Api.Response
function ResponseTemplates.Ok(value)
	return Response(value, { Code = StatusCodes.Status200OK })
end

function ResponseTemplates.Accepted(value)
	return Response(value, { Code = StatusCodes.Status202Accepted })
end

---@param message string
---@return Net.Rest.Api.Response
function ResponseTemplates.BadRequest(message)
	return Response(nil, { Code = StatusCodes.Status400BadRequest, Message = message })
end

---@param message string
---@return Net.Rest.Api.Response
function ResponseTemplates.NotFound(message)
	return Response(nil, { Code = StatusCodes.Status404NotFound, Message = message })
end

---@param message string
---@return Net.Rest.Api.Response
function ResponseTemplates.InternalServerError(message)
	return Response(nil, { Code = StatusCodes.Status500InternalServerError, Message = message })
end

return ResponseTemplates
