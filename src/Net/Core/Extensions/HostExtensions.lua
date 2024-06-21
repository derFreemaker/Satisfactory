---@type Out<Github_Loading.Module>
local Host = {}
if not PackageLoader:TryGetModule("Hosting.Host", Host) then
    return
end
---@type Hosting.Host
Host = Host.Value:Load()

local Task = require("Core.Common.Task")
local NetworkClient = require("Net.Core.NetworkClient")

---@class Hosting.Host
---@field package m_networkClient Net.Core.NetworkClient
local HostExtensions = {}

---@param networkClient Net.Core.NetworkClient
function HostExtensions:SetNetworkClient(networkClient)
    self.m_networkClient = networkClient
end

---@return Net.Core.NetworkClient
function HostExtensions:GetNetworkClient()
    if not self.m_networkClient then
        self.m_networkClient = NetworkClient(self:CreateLogger("NetworkClient"), nil, self:GetJsonSerializer())
    end

    return self.m_networkClient
end

---@param port Net.Core.Port
---@return Net.Core.NetworkPort networkPort
function HostExtensions:CreateNetworkPort(port)
    return self:GetNetworkClient():GetOrCreateNetworkPort(port)
end

---@param port Net.Core.Port
---@param outNetworkPort Out<Net.Core.NetworkPort>
---@return boolean exists
function HostExtensions:NetworkPortExists(port, outNetworkPort)
    local netPort = self:GetNetworkClient():GetNetworkPort(port)
    if not netPort then
        return false
    end

    outNetworkPort.Value = netPort
    return true
end

---@param port Net.Core.Port
---@return Net.Core.NetworkPort networkPort
function HostExtensions:GetNetworkPort(port)
    ---@type Out<Net.Core.NetworkPort>
    local outNetPort = {}
    if self:NetworkPortExists(port, outNetPort) then
        return outNetPort.Value
    end

    return self:CreateNetworkPort(port)
end

---@param port Net.Core.Port
---@param eventName Net.Core.EventName
---@param task Core.Task
---@return Net.Core.NetworkPort netPort,  number eventTaskIndex
function HostExtensions:AddCallableEventTask(port, eventName, task)
    local netPort = self:CreateNetworkPort(port)
    local taskIndex = netPort:AddTask(eventName, task)
    netPort:OpenPort()
    return netPort, taskIndex
end

---@param port Net.Core.Port
---@param eventName Net.Core.EventName
---@param listener fun(context: Net.Core.NetworkContext)
---@return Net.Core.NetworkPort netPort,  number eventTaskIndex
function HostExtensions:AddCallableEventListener(port, eventName, listener)
    return self:AddCallableEventTask(port, eventName, Task(listener))
end

---@param eventName string
---@param port Net.Core.Port
function HostExtensions:RemoveCallableEvent(eventName, port)
    local netPort = self:GetNetworkPort(port)
    netPort:RemoveEvent(eventName)
end

return Utils.Class.Extend(Host, HostExtensions)
