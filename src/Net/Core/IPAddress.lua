---@class Net.Core.IPAddress : Core.Json.Serializable
---@field private _Address string
---@overload fun(address: string) : Net.Core.IPAddress
local IPAddress = {}

---@private
---@param address string
function IPAddress:__init(address)
    self._Address = address
end

function IPAddress:GetAddress()
    return self._Address
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
    return self._Address
end

--#endregion

return Utils.Class.CreateClass(IPAddress, "Core.IPAddress", require("Core.Json.Serializable"))
