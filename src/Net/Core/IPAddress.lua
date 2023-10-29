---@class Net.Core.IPAddress : Core.Json.Serializable
---@field private m_address string
---@overload fun(address: string) : Net.Core.IPAddress
local IPAddress = {}

---@private
---@param address string
function IPAddress:__init(address)
    self:__modifyBehavior({ DisableCustomIndexing = true })
    self.m_address = address
    self:__modifyBehavior({ DisableCustomIndexing = false })
end

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
function IPAddress.__eq(left, right)
    if not Utils.Class.HasBaseClass(left, "Net.Core.IPAddress") then
        error("expected left Net.Core.IPAddress, got " .. type(left))
    end
    if not Utils.Class.HasBaseClass(right, "Net.Core.IPAddress") then
        error("expected right Net.Core.IPAddress, got " .. type(right))
    end
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
