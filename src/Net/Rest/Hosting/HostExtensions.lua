local ApiController = require("Net.Rest.Api.Server.Controller")

---@class Hosting.Host
local HostExtensions = {}

---@type Dictionary<integer | "all", Net.Rest.Api.Server.Controller>
HostExtensions.ApiControllers = {}

---@param port integer | "all"
---@param endpointLogger Core.Logger
---@param endpointBase Net.Rest.Api.Server.EndpointBase
function HostExtensions:AddEndpointBase(port, endpointLogger, endpointBase)
    local netPort = self._NetworkClient:GetOrCreateNetworkPort(port)
    local apiController = self.ApiControllers[port] or ApiController(netPort, endpointLogger:subLogger("ApiController"))
    apiController:AddEndpointBase(endpointBase)
    netPort:OpenPort()

    self.ApiControllers[port] = apiController
end

return Utils.Class.ExtendClass(HostExtensions, require("Hosting.Host") --[[@as Hosting.Host]])
