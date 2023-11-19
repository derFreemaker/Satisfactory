---@class Net.Core.IPAddress : Core.Json.Serializable
---@field private m_address FIN.UUID
---@overload fun(address: string) : Net.Core.IPAddress
local IPAddress = {}

---@private
---@param address FIN.UUID
function IPAddress:__init(address)
    self:Raw__ModifyBehavior({ DisableCustomIndexing = true })
    self.m_address = address
    self:Raw__ModifyBehavior({ DisableCustomIndexing = false })
end

---@return FIN.UUID
function IPAddress:GetAddress()
    return self.m_address
end

---@param ipAddress Net.Core.IPAddress
function IPAddress:Equals(ipAddress)
    return self:GetAddress() == ipAddress:GetAddress()
end

---@private
function IPAddress:__newindex()
    error("Net.Core.IPAddress is read only.")
end

---@private
function IPAddress:__tostring()
    return self:GetAddress()
end

--#region - Serializable -

---@return string address
function IPAddress:Serialize()
    return self.m_address
end

--#endregion

return Utils.Class.CreateClass(IPAddress, "Net.Core.IPAddress", require("Core.Json.Serializable"))
