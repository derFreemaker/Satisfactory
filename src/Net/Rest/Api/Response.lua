---@class Net.Rest.Api.Response.Header
---@field Code Net.Core.StatusCodes

---@class Net.Rest.Api.Response
---@field Headers Net.Rest.Api.Response.Header | Dictionary<string, any>
---@field Body any
---@field WasSuccessfull boolean
---@overload fun(body: any, header: (Net.Rest.Api.Response.Header | Dictionary<string, any>)?) : Net.Rest.Api.Response
local Response = {}

---@private
---@param body any
---@param header (Net.Rest.Api.Response.Header | Dictionary<string, any>)?
function Response:__init(body, header)
	self.Headers = header or {}
	self.Body = body
	if type(self.Headers.Code) == 'number' then
		self.WasSuccessfull = self.Headers.Code < 300
	else
		self.WasSuccessfull = false
	end
end

---@return table
function Response:ExtractData()
	return {
		Headers = self.Headers,
		Body = self.Body
	}
end

return Utils.Class.CreateClass(Response, 'Net.Rest.Api.Response')
