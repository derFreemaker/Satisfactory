local NetworkClient = require("Net.Core.NetworkClient")

---@class Hosting.Host
---@field private _NetworkClient Net.Core.NetworkClient
local HostExtensions = {}

---@private
function HostExtensions:CheckNetworkClient()
    if self._NetworkClient then
        return
    end

    self._NetworkClient = NetworkClient(self._Logger:subLogger("NetworkClient"), nil, self._JsonSerializer)
end

---@param networkClient Net.Core.NetworkClient
function HostExtensions:SetNetworkClient(networkClient)
    self._NetworkClient = networkClient
end

---@return Net.Core.NetworkClient
function HostExtensions:GetNetworkClient()
    self:CheckNetworkClient()

    return self._NetworkClient
end

---@param port integer | "all"
---@return Net.Core.NetworkPort networkPort
function HostExtensions:CreateNetworkPort(port)
    self:CheckNetworkClient()

    return self._NetworkClient:GetOrCreateNetworkPort(port)
end

---@param port integer | "all"
---@param outNetworkPort Out<Net.Core.NetworkPort>
---@return boolean exists
function HostExtensions:NetworkPortExists(port, outNetworkPort)
    self:CheckNetworkClient()

    local netPort = self._NetworkClient:GetNetworkPort(port)
    if not netPort then
        return false
    end

    outNetworkPort.Return = netPort
    return true
end

---@param port integer | "all"
---@return Net.Core.NetworkPort networkPort
function HostExtensions:GetNetworkPort(port)
    ---@type Out<Net.Core.NetworkPort>
    local outNetPort = {}
    if self:NetworkPortExists(port, outNetPort) then
        return outNetPort.Return
    end

    return self:CreateNetworkPort(port)
end

---@param eventName string
---@param port integer | "all"
---@param task Core.Task
function HostExtensions:AddCallableEvent(eventName, port, task)
    local netPort = self:CreateNetworkPort(port)
    netPort:AddListener(eventName, task)
    netPort:OpenPort()
end

---@param eventName string
---@param port integer | "all"
function HostExtensions:RemoveCallableEvent(eventName, port)
    local netPort = self:GetNetworkPort(port)
    netPort:RemoveListener(eventName)
end

return Utils.Class.ExtendClass(HostExtensions, require("Hosting.Host") --[[@as Hosting.Host]])
