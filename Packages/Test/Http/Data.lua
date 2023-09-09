local PackageData = {}

-- ########## Test.Http ##########

PackageData.MFYoiWSx = {
    Namespace = "Test.Http.__main",
    Name = "__main",
    FullName = "__main.lua",
    IsRunnable = true,
    Data = [[
local EventPullAdapter = require("Core.Event.EventPullAdapter")
local NetworkClient = require("Core.Net.NetworkClient")
local DNSClient = require("DNS.Client.DNSClient")

---@class Test.Http.Main : Github_Loading.Entities.Main
---@field private netClient Core.Net.NetworkClient
---@field private dnsClient DNS.Client
local Main = {}

function Main:Configure()
    EventPullAdapter:Initialize(self.Logger:subLogger("EventPullAdapter"))

    self.netClient = NetworkClient(self.Logger:subLogger("NetworkClient"))
    self.dnsClient = DNSClient(self.netClient, self.Logger:subLogger("DNS_Client"))
end

function Main:Run()
    local domain = "factoryControl.de"

    self.Logger:LogDebug("getting dns server address...")
    self.dnsClient:GetDNSServerAddressIfNeeded()
    self.Logger:LogInfo("got dns server address")

    self.Logger:LogDebug("creating address on server...")
    local createdAddress = self.dnsClient:CreateAddress(domain, self.netClient:GetId())
    assert(createdAddress, "unable to create address on dns server")
    self.Logger:LogInfo("created address on server")

    self.Logger:LogDebug("getting address back from server...")
    local getedAddress = self.dnsClient:GetWithAddress(domain)
    assert(getedAddress, "unable to get address from dns server")
    self.Logger:LogInfo("got address back from server...")

    log(getedAddress.Address, getedAddress.Id, " -> ", self.netClient:GetId())
end

return Main
]]
}

-- ########## Test.Http ########## --

return PackageData
