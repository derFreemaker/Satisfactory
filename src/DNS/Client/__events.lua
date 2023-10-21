local Task = require("Core.Task")

local Host = require("Hosting.Host")
local DNSClient = require("DNS.Client.Client")

---@class DNS.Client.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    ---@param host Hosting.Host
    local function readyTaskWaitForDNSServer(host)
        DNSClient.Static_WaitForHeartbeat(host:GetNetworkClient())
    end

    table.insert(Host._Static__ReadyTasks, Task(readyTaskWaitForDNSServer))
end

return Events
