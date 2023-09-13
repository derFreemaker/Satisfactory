local RestApiEndpointBase = require("Net.Rest.RestApii.Server.RestApiEndpointBase")

---@class FactoryControl.Server.Endpoints.ControllerEndpoints : Core.RestApi.Server.RestApiEndpointBase
local ControllerEndpoints = {}

---@param request Core.RestApi.RestApiRequest
---@return Core.RestApi.RestApiResponse response
function ControllerEndpoints:CREATE__Controller(request)
    return self.Templates:Ok(true)
end

return Utils.Class.CreateClass(ControllerEndpoints, "ControllerEndpoints", RestApiEndpointBase)