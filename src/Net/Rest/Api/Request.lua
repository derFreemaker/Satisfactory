---@class Net.Rest.Api.Request : object
---@field Method Net.Rest.Api.Method
---@field Endpoint string
---@field Headers Dictionary<string, any>
---@field Body any
---@overload fun(method: Net.Rest.Api.Method, endpoint: string, body: any, headers: Dictionary<string, any>?) : Net.Rest.Api.Request
local Request = {}

---@private
---@param method Net.Rest.Api.Method
---@param endpoint string
---@param body any
---@param headers Dictionary<string, any>?
function Request:__init(method, endpoint, body, headers)
    self.Method = method
    self.Endpoint = endpoint
    self.Headers = headers or {}
    self.Body = body
end

---@return table
function Request:ExtractData()
    return {
        Method = self.Method,
        Endpoint = self.Endpoint,
        Headers = self.Headers,
        Body = self.Body
    }
end

return Utils.Class.CreateClass(Request, "Net.Rest.Api.Request")
