---@type Out<Github_Loading.Module>
local Host = {}
if not PackageLoader:TryGetModule("Hosting.Host", Host) then
    return
end
---@type Hosting.Host
Host = Host.Return:Load()
-- Run only if module Hosting.Host is loaded

local Task = require("Core.Task")

local DNSClient = require("DNS.Client.Client")

---@param host Hosting.Host
local function readyTaskWaitForDNSServer(host)
    DNSClient.Static_WaitForHeartbeat(host:GetNetworkClient())
end

table.insert(Host._Static__ReadyTasks, Task(readyTaskWaitForDNSServer))

---@class Hosting.Host
---@field package _DNSClient DNS.Client
local HostExtensions = {}

function HostExtensions:GetDNSClient()
    if not self._DNSClient then
        self._DNSClient = DNSClient(self:GetNetworkClient(), self._Logger:subLogger("DNSClient"))
    end

    return self._DNSClient
end

---@param url string
---@param ipAddress Net.Core.IPAddress?
function HostExtensions:RegisterAddress(url, ipAddress)
    local dnsClient = self:GetDNSClient()

    if not ipAddress then
        ipAddress = self:GetNetworkClient():GetIPAddress()
    end

    if dnsClient:CreateAddress(url, ipAddress) then
        self._Logger:LogInfo("Registered address " .. url .. " on DNS server.")
    else
        self._Logger:LogError("Failed to register address " .. url .. " on DNS server or already exists.")
    end
end

Utils.Class.ExtendClass(HostExtensions, Host)
