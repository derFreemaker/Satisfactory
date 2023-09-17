---@class Http.Request.Options : object
---@field Headers Dictionary<string, any>
---@field Timeout integer in seconds
---@overload fun() : Http.Request.Options
local HttpRequestOptions = {}

---@private
function HttpRequestOptions:__init()
	self.Headers = {}
	self.Timeout = 10
end

return Utils.Class.CreateClass(HttpRequestOptions, 'Http.HttpRequestOptions')
