---@type Out<Github_Loading.Module>
local Host = {}
if not PackageLoader:TryGetModule("Hosting.Host", Host) then
    return
end
---@type Hosting.Host
Host = Host.Return:Load()
-- Run only if module Hosting.Host is loaded

local ApiController = require("Net.Rest.Api.Server.Controller")

---@class Hosting.Host
---@field ApiControllers Dictionary<integer | "all", Net.Rest.Api.Server.Controller>
---@field Endpoints Net.Rest.Api.Server.EndpointBase[]
local HostExtensions = {}

---@param port integer | "all"
---@param endpointLogger Core.Logger
---@return Net.Rest.Api.Server.Controller apiController
function HostExtensions:GetOrCreateApiController(port, endpointLogger)
    if not self.ApiControllers then
        self.ApiControllers = {}
    end

    local apiController = self.ApiControllers[port]
    if not apiController then
        local netPort = self._NetworkClient:GetOrCreateNetworkPort(port)
        apiController = ApiController(netPort, endpointLogger:subLogger("ApiController"))
        self.ApiControllers[port] = apiController
    end

    return apiController
end

---@param port integer | "all"
---@param endpointName string
---@param endpointBase Net.Rest.Api.Server.EndpointBase
function HostExtensions:AddEndpoint(port, endpointName, endpointBase)
    if not self.Endpoints then
        self.Endpoints = {}
    end

    local endpointLogger = self._Logger:subLogger("Endpoint[" .. endpointName .. "]")
    local apiController = self:GetOrCreateApiController(port, endpointLogger)

    table.insert(self.Endpoints, endpointBase(endpointLogger, apiController))
end

return Utils.Class.ExtendClass(HostExtensions, Host)
