---@class Http.HttpRequestOptions : object
---@field Headers Dictionary<string, any>
---@overload fun() : Http.HttpRequestOptions
local HttpRequestOptions = {}

---@private
function HttpRequestOptions:__init()
	self.Headers = {}
end

return Utils.Class.CreateClass(HttpRequestOptions, 'Http.HttpRequestOptions')
