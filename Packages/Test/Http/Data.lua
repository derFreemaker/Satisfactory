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

    local createdAddress = self.dnsClient:CreateAddress(domain, self.netClient:GetId())
    assert(createdAddress, "unable to create address on dns server")

    local getedAddress = self.dnsClient:GetWithAddress(domain)
    assert(getedAddress, "unable to get address from dns server")

    log(getedAddress.Address, getedAddress.Id)
end

return Main
]]
}

-- ########## Test.Http ########## --

return PackageData
