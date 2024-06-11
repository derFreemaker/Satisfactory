---@class Net.Rest.Api.Response.Header : table<string, any>
---@field Code Net.Core.StatusCodes

---@class Net.Rest.Api.Response : object, Core.Json.Serializable
---@field Headers Net.Rest.Api.Response.Header
---@field Body any
---@field WasSuccessful boolean
---@overload fun(body: any, header: (Net.Rest.Api.Response.Header)?) : Net.Rest.Api.Response
local Response = {}

---@private
---@param body any
---@param header (Net.Rest.Api.Response.Header)?
function Response:__init(body, header)
    self.Body = body
    self.Headers = header or {}
    if type(self.Headers.Code) == "number" then
        self.WasSuccessful = self.Headers.Code < 300
    else
        self.WasSuccessful = false
    end
end

---@return Net.Rest.Api.Response.Header headers, any body
function Response:Serialize()
    return self.Body, self.Headers
end

return class("Net.Rest.Api.Response", Response,
    { Inherit = require("Core.Json.Serializable") })
