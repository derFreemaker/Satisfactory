---@type Out<Github_Loading.Module>
local Host = {}
if not PackageLoader:TryGetModule("Hosting.Host", Host) then
    return
end
---@type Hosting.Host
Host = Host.Value:Load()

local Task = require("Core.Common.Task")

local DNSClient = require("DNS.Client.Client")

---@param host Hosting.Host
local function readyTaskWaitForDNSServer(host)
    DNSClient.Static__WaitForHeartbeat(host:GetNetworkClient())
end

table.insert(Host.Static__ReadyTasks, Task(readyTaskWaitForDNSServer))

---@class Hosting.Host
---@field package m_dnsClient DNS.Client
local HostExtensions = {}

function HostExtensions:GetDNSClient()
    if not self.m_dnsClient then
        self.m_dnsClient = DNSClient(self:GetNetworkClient(), self:CreateLogger("DNSClient"))
    end

    return self.m_dnsClient
end

---@param url string
---@param ipAddress Net.Core.IPAddress?
function HostExtensions:RegisterAddress(url, ipAddress)
    local dnsClient = self:GetDNSClient()

    if not ipAddress then
        ipAddress = self:GetNetworkClient():GetIPAddress()
    end

    if dnsClient:CreateAddress(url, ipAddress) then
        self:GetHostLogger():LogDebug("Registered address " .. url .. " on DNS server.")
    else
        self:GetHostLogger():LogWarning("Failed to register address " .. url .. " on DNS server or already exists.")
    end
end

Utils.Class.Extend(Host, HostExtensions)
