---@class Core.IPAddress : Core.Json.Serializable
---@field private _Address string
---@overload fun(address: string) : Core.IPAddress
local IPAddress = {}

---@private
---@param address string
function IPAddress:__init(address)
    self._Address = address
end

function IPAddress:GetAddress()
    return self._Address
end

--#region - Serializable -

---@return table data
function IPAddress:Static__Serialize()
    return self._Address
end

---@param data table
---@return Core.IPAddress
function IPAddress.Static__Deserialize(data)
    return IPAddress(data)
end

--#endregion

return Utils.Class.CreateClass(IPAddress, "Core.IPAddress", require("Core.Json.Serializable"))
