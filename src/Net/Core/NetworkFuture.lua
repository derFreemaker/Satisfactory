---@class Net.Core.NetworkFuture : object
---@field private _EventName string
---@field private _Port Net.Core.Port
---@field private _Timeout number?
---@field private _NetworkClient Net.Core.NetworkClient
---@overload fun(networkClient: Net.Core.NetworkClient, eventName: string, port: Net.Core.Port, timeout: number?) : Net.Core.NetworkFuture
local NetworkFuture = {}

---@private
---@param networkClient Net.Core.NetworkClient
---@param eventName string
---@param port Net.Core.Port
---@param timeout number?
function NetworkFuture:__init(networkClient, eventName, port, timeout)
    self._EventName = eventName
    self._Port = port
    self._Timeout = timeout
    self._NetworkClient = networkClient

    if type(port) == "number" then
        self._NetworkClient:Open(port)
    end
end

---@async
---@return Net.Core.NetworkContext?
function NetworkFuture:Wait()
    return self._NetworkClient:WaitForEvent(self._EventName, self._Port, self._Timeout)
end

return Utils.Class.CreateClass(NetworkFuture, 'Core.Net.NetworkFuture')
