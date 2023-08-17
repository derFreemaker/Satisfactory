local StatusCodes = require("Core.Api.StatusCodes")

---@class Core.Api.ApiResponse.Header
---@field Code Core.Api.StatusCodes

---@class Core.Api.ApiResponse
---@field Header Core.Api.ApiResponse.Header | Dictionary<string, any>
---@field Body any
---@field WasSuccessfull boolean
---@overload fun(header: (Core.Api.ApiResponse.Header | Dictionary<string, any>)?, body: any) : Core.Api.ApiResponse
local ApiResponse = {}

---@private
---@param header (Core.Api.ApiResponse.Header | Dictionary<string, any>)?
---@param body any
function ApiResponse:ApiResponse(header, body)
    self.Header = header or {}
    self.Body = body
    self.WasSuccessfull = self.Header.Code == StatusCodes.Status200OK
end

return Utils.Class.CreateClass(ApiResponse, "ApiResponse")