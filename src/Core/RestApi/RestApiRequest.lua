---@class Core.RestApi.RestApiRequest : object
---@field Method Core.RestApi.RestApiMethod
---@field Endpoint string
---@field Headers Dictionary<string, any>
---@field Body any
---@overload fun(method: Core.RestApi.RestApiMethod, endpoint: string, headers: Dictionary<string, any>?, body: any) : Core.RestApi.RestApiRequest
local RestApiRequest = {}

---@private
---@param method Core.RestApi.RestApiMethod
---@param endpoint string
---@param headers Dictionary<string, any>?
---@param body any
function RestApiRequest:__call(method, endpoint, headers, body)
    self.Method = method
    self.Endpoint = endpoint
    self.Headers = headers or {}
    self.Body = body
end

---@return table
function RestApiRequest:ExtractData()
    return {
        Method = self.Method,
        Endpoint = self.Endpoint,
        Headers = self.Headers,
        Body = self.Body
    }
end

---@param context Core.Net.NetworkContext
function RestApiRequest.Static__CreateFromNetworkContext(context)
    return RestApiRequest(context.Body.Method, context.Body.Endpoint, context.Body.Headers, context.Body.Body)
end

return Utils.Class.CreateClass(RestApiRequest, "Core.RestApi.RestApiRequest")
