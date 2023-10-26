---@class Net.Http.Request.Options : object
---@field Headers table<string, any>
---@field Timeout integer in seconds
---@overload fun() : Net.Http.Request.Options
local HttpRequestOptions = {}

---@private
function HttpRequestOptions:__init()
	self.Headers = {}
	self.Timeout = 10
end

return Utils.Class.CreateClass(HttpRequestOptions, 'Http.HttpRequestOptions')
