---@class Net.Core.NetworkFuture : object
---@field private m_eventName string
---@field private m_port Net.Core.Port
---@field private m_timeoutSeconds number?
---@field private m_networkClient Net.Core.NetworkClient
---@overload fun(networkClient: Net.Core.NetworkClient, eventName: string, port: Net.Core.Port, timeoutSeconds: number?) : Net.Core.NetworkFuture
local NetworkFuture = {}

---@private
---@param networkClient Net.Core.NetworkClient
---@param eventName string
---@param port Net.Core.Port
---@param timeoutSeconds number?
function NetworkFuture:__init(networkClient, eventName, port, timeoutSeconds)
    self.m_eventName = eventName
    self.m_port = port
    self.m_timeoutSeconds = timeoutSeconds
    self.m_networkClient = networkClient

    if type(port) == "number" then
        self.m_networkClient:Open(port)
    end
end

---@async
---@return Net.Core.NetworkContext?
function NetworkFuture:Wait()
    return self.m_networkClient:WaitForEvent(self.m_eventName, self.m_port, self.m_timeoutSeconds)
end

return Utils.Class.CreateClass(NetworkFuture, 'Core.Net.NetworkFuture')
