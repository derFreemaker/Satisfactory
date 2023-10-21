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
