---@class DNS.Core.Entities.Address : Core.Json.Serializable
---@field Id Core.UUID
---@field Url string
---@field IPAddress Net.Core.IPAddress
---@overload fun(id: Core.UUID, url: string, ipAddress: Net.Core.IPAddress) : DNS.Core.Entities.Address
local Address = {}

---@private
---@param id Core.UUID
---@param url string
---@param ipAddress Net.Core.IPAddress
function Address:__init(id, url, ipAddress)
    self.Id = id
    self.Url = url
    self.IPAddress = ipAddress
end

---@return Core.UUID id, string address, Net.Core.IPAddress ipAddress
function Address:Serialize()
    return self.Id, self.Url, self.IPAddress
end

return Utils.Class.CreateClass(Address, "DNS.Entities.Address",
    require("Core.Json.Serializable"))
