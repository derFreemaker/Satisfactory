---@class Net.Core.NetworkFuture : object
---@field private m_eventName string
---@field private m_port Net.Core.Port
---@field private m_timeout number?
---@field private m_networkClient Net.Core.NetworkClient
---@overload fun(networkClient: Net.Core.NetworkClient, eventName: string, port: Net.Core.Port, timeout: number?) : Net.Core.NetworkFuture
local NetworkFuture = {}

---@private
---@param networkClient Net.Core.NetworkClient
---@param eventName string
---@param port Net.Core.Port
---@param timeout number?
function NetworkFuture:__init(networkClient, eventName, port, timeout)
    self.m_eventName = eventName
    self.m_port = port
    self.m_timeout = timeout
    self.m_networkClient = networkClient

    if type(port) == "number" then
        self.m_networkClient:Open(port)
    end
end

---@async
---@return Net.Core.NetworkContext?
function NetworkFuture:Wait()
    return self.m_networkClient:WaitForEvent(self.m_eventName, self.m_port, self.m_timeout)
end

return Utils.Class.CreateClass(NetworkFuture, 'Core.Net.NetworkFuture')
