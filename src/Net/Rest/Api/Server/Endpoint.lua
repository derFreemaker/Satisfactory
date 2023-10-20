local EventNameUsage = require("Core.Usage.Usage_EventName")

local RestApiResponseTemplates = require('Net.Rest.Api.Server.ResponseTemplates')

---@class Net.Rest.Api.Server.Endpoint : object
---@field private _Task Core.Task
---@field private _Logger Core.Logger
---@overload fun(task: Core.Task, logger: Core.Logger) : Net.Rest.Api.Server.Endpoint
local Endpoint = {}

---@private
---@param task Core.Task
---@param logger Core.Logger
function Endpoint:__init(task, logger)
	self._Task = task
	self._Logger = logger
end

---@param request Net.Rest.Api.Request
---@param context Net.Core.NetworkContext
---@param netClient Net.Core.NetworkClient
function Endpoint:Execute(request, context, netClient)
	self._Logger:LogTrace('executing...')
	___logger:setLogger(self._Logger)
	self._Task:Execute(request)
	self._Task:LogError(self._Logger)
	___logger:revert()
	---@type Net.Rest.Api.Response
	local response = self._Task:GetResults()
	if not self._Task:IsSuccess() then
		response = RestApiResponseTemplates.InternalServerError(tostring(self._Task:GetTraceback()))
	end
	if context.Header.ReturnPort then
		self._Logger:LogTrace("sending response to '" ..
			context.SenderIPAddress .. "' on port: " .. context.Header.ReturnPort .. '...')
		netClient:Send(
			context.SenderIPAddress,
			context.Header.ReturnPort,
			EventNameUsage.RestResponse,
			response:ExtractData()
		)
	else
		self._Logger:LogTrace('sending no response')
	end
	if response.Headers.Message == nil then
		self._Logger:LogDebug('request finished with status code: ' .. response.Headers.Code)
	else
		self._Logger:LogDebug('request finished with status code: ' ..
			response.Headers.Code .. " with message: '" .. response.Headers.Message .. "'")
	end
end

return Utils.Class.CreateClass(Endpoint, 'Net.Rest.Api.Server.Endpoint')
