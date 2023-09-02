local DNSEndpoints = require("DNS.Endpoints")
local NetworkClient = require("Core.Net.NetworkClient")
local Task = require("Core.Task")

---@class DNS.Main : Github_Loading.Entities.Main
---@field private eventPullAdapter Core.EventPullAdapter
---@field private netPort Core.Net.NetworkPort
---@field private endpoints DNS.Endpoints
local Main = {}

---@param context Core.Net.NetworkContext
function Main:GetDNSServerAddress(context)
    local netClient = self.netPort:GetNetClient()
    local id = netClient:GetId()
    netClient:SendMessage(context.SenderIPAddress, 53, "ReturnDNSServerAddress", id)
end

function Main:Configure()
    self.eventPullAdapter = require("Core.Event.EventPullAdapter"):Initialize(self.Logger:subLogger("EventPullAdapter"))

    local dnsLogger = self.Logger:subLogger("DNSServerAddress")
    local netClient = NetworkClient(dnsLogger:subLogger("NetworkClient"))
    self.netPort = netClient:CreateNetworkPort(53)
    self.netPort:AddListener("GetDNSServerAddress", Task(self.GetDNSServerAddress, self))

    self.netPort:OpenPort()
    self.endpoints = DNSEndpoints(self.Logger:subLogger("DNS.Endpoints"))
end

function Main:Run()
    self.eventPullAdapter:Run()
end

return Main
