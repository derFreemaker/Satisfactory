---@class Core.RestApi.RestApiResponse.Header
---@field Code Core.RestApi.StatusCodes

---@class Core.RestApi.RestApiResponse
---@field Headers Core.RestApi.RestApiResponse.Header | Dictionary<string, any>
---@field Body any
---@field WasSuccessfull boolean
---@overload fun(body: any, header: (Core.RestApi.RestApiResponse.Header | Dictionary<string, any>)?) : Core.RestApi.RestApiResponse
local RestApiResponse = {}

---@private
---@param body any
---@param header (Core.RestApi.RestApiResponse.Header | Dictionary<string, any>)?
function RestApiResponse:__call(body, header)
    self.Headers = header or {}
    self.Body = body
    self.WasSuccessfull = self.Headers.Code < 300
end

---@return table
function RestApiResponse:ExtractData()
    return {
        Headers = self.Headers,
        Body = self.Body
    }
end

---@param context Core.Net.NetworkContext
function RestApiResponse.Static__CreateFromNetworkContext(context)
    return RestApiResponse(context.Body.Headers, context.Body.Body)
end

return Utils.Class.CreateClass(RestApiResponse, "Core.RestApi.RestApiResponse")
