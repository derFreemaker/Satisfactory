---@type Out<Github_Loading.Module>
local Host = {}
if not PackageLoader:TryGetModule("Hosting.Host", Host) then
    return
end
---@type Hosting.Host
Host = Host.Value:Load()
-- Run only if module Hosting.Host is loaded

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
        self.m_networkClient = NetworkClient(self.m_logger:subLogger("NetworkClient"), nil, self.m_jsonSerializer)
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

---@param eventName string
---@param port Net.Core.Port
---@param task Core.Task
function HostExtensions:AddCallableEvent(eventName, port, task)
    local netPort = self:CreateNetworkPort(port)
    netPort:AddListener(eventName, task)
    netPort:OpenPort()
end

---@param eventName string
---@param port Net.Core.Port
function HostExtensions:RemoveCallableEvent(eventName, port)
    local netPort = self:GetNetworkPort(port)
    netPort:RemoveListener(eventName)
end

return Utils.Class.ExtendClass(HostExtensions, Host)
