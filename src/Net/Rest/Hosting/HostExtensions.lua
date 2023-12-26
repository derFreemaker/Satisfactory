---@type Out<Github_Loading.Module>
local Host = {}
if not PackageLoader:TryGetModule("Hosting.Host", Host) then
    return
end
---@type Hosting.Host
Host = Host.Value:Load()

local ApiController = require("Net.Rest.Api.Server.Controller")

---@class Hosting.Host
---@field package ApiControllers table<Net.Core.Port, Net.Rest.Api.Server.Controller>
---@field package Endpoints Net.Rest.Api.Server.EndpointBase[]
local HostExtensions = {}

---@param port Net.Core.Port
---@param endpointLogger Core.Logger
---@return Net.Rest.Api.Server.Controller apiController
function HostExtensions:GetOrCreateApiController(port, endpointLogger)
    if not self.ApiControllers then
        self.ApiControllers = {}
    end

    local apiController = self.ApiControllers[port]
    if not apiController then
        local netPort = self:GetNetworkClient():GetOrCreateNetworkPort(port)
        apiController = ApiController(netPort, endpointLogger:subLogger("ApiController"))
        self.ApiControllers[port] = apiController
        netPort:OpenPort()
    end

    return apiController
end

---@param port Net.Core.Port
---@param endpointName string
---@param endpointBase Net.Rest.Api.Server.EndpointBase
---@param ... any constructor args that are not logger and apiController
function HostExtensions:AddEndpoint(port, endpointName, endpointBase, ...)
    if not self.Endpoints then
        self.Endpoints = {}
    end

    local endpointLogger = self:CreateLogger("Endpoint[" .. endpointName .. "]")
    local apiController = self:GetOrCreateApiController(port, endpointLogger)

    table.insert(self.Endpoints, endpointBase(endpointLogger, apiController, ...))
end

return Utils.Class.ExtendClass(Host, HostExtensions)
