---@class Core.Api.ApiRequest : object
---@field Endpoint string
---@field Headers Dictionary<string, any>
---@field Body any
---@overload fun(endpoint: string, headers: Dictionary<string, any>?, body: any) : Core.Api.ApiRequest
local ApiRequest = {}

---@private
---@param endpoint string
---@param headers Dictionary<string, any>?
---@param body any
function ApiRequest:ApiRequest(endpoint, headers, body)
    self.Endpoint = endpoint
    self.Headers = headers or {}
    self.Body = body
end

---@return table
function ApiRequest:ExtractData()
    return {
        Endpoint = self.Endpoint,
        Headers = self.Headers,
        Body = self.Body
    }
end

return Utils.Class.CreateClass(ApiRequest, "ApiRequest")