---@class Net.Rest.Api.Request : object, Core.Json.Serializable
---@field Method Net.Core.Method
---@field Endpoint Net.Rest.Uri
---@field Headers table<string, any>
---@field Body any
---@overload fun(method: Net.Core.Method, endpoint: Net.Rest.Uri, body: any, headers: table<string, any>?) : Net.Rest.Api.Request
local Request = {}

---@private
---@param method Net.Core.Method
---@param endpoint Net.Rest.Uri
---@param body any
---@param headers table<string, any>?
function Request:__init(method, endpoint, body, headers)
    self.Method = method
    self.Endpoint = endpoint
    self.Body = body
    self.Headers = headers or {}
end

---@return Net.Core.Method method, Net.Rest.Uri endpoint, any body, table<string, any> headers
function Request:Serialize()
    return self.Method, self.Endpoint, self.Body, self.Headers
end

return class("Net.Rest.Api.Request", Request,
    { Inherit = require("Core.Json.Serializable") })
