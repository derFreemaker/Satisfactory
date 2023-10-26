---@class Net.Rest.Api.Response.Header : table<string, any>
---@field Code Net.Core.StatusCodes
---@field Message string?

---@class Net.Rest.Api.Response : Core.Json.Serializable
---@field Headers Net.Rest.Api.Response.Header
---@field Body any
---@field WasSuccessfull boolean
---@overload fun(body: any, header: (Net.Rest.Api.Response.Header)?) : Net.Rest.Api.Response
local Response = {}

---@private
---@param body any
---@param header (Net.Rest.Api.Response.Header)?
function Response:__init(body, header)
    self.Body = body
    self.Headers = header or {}
    if type(self.Headers.Code) == 'number' then
        self.WasSuccessfull = self.Headers.Code < 300
    else
        self.WasSuccessfull = false
    end
end

---@return Net.Rest.Api.Response.Header headers, any body
function Response:Serialize()
    return self.Headers, self.Body
end

---@param headers Net.Rest.Api.Response.Header
---@param body any
---@return Net.Rest.Api.Response
function Response:Static__Deserialize(headers, body)
    return self(body, headers)
end

return Utils.Class.CreateClass(Response, "Net.Rest.Api.Response",
    require("Core.Json.Serializable"))
