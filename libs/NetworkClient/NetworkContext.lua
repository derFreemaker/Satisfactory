local Serializer = require("libs.Serializer")

---@class NetworkContext
---@field SignalName string
---@field SignalSender string
---@field SenderIPAddress string
---@field Port number
---@field EventName string
---@field Header table
---@field Body table
local NetworkContext = {}
NetworkContext.__index = NetworkContext

---@param signalName string
---@param signalSender string
---@param senderIPAddress string
---@param port number
---@param eventName string
---@param header table | nil
---@param body table | nil
---@return NetworkContext
function NetworkContext.new(signalName, signalSender, senderIPAddress, port, eventName, header, body)
    return setmetatable({
        SignalName = signalName,
        SignalSender = signalSender,
        SenderIPAddress = senderIPAddress,
        Port = port,
        EventName = eventName,
        Header = header or {},
        Body = body or {}
    }, NetworkContext)
end

---@param signalName string
---@param signalSender string
---@param extractedData table
---@return NetworkContext
function NetworkContext.Parse(signalName, signalSender, extractedData)
    return NetworkContext.new(signalName, signalSender, extractedData.SenderIPAddress, extractedData.Port,
        extractedData.EventName, Serializer:Deserialize(extractedData.Body), Serializer:Deserialize(extractedData.Header))
end

return NetworkContext
