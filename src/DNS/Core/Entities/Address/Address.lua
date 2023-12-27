---@class DNS.Core.Entities.Address : Core.Json.Serializable
---@field Id Core.UUID
---@field Domain string
---@field IPAddress Net.Core.IPAddress
---@overload fun(id: Core.UUID, domain: string, ipAddress: Net.Core.IPAddress) : DNS.Core.Entities.Address
local Address = {}

---@private
---@param id Core.UUID
---@param domain string
---@param ipAddress Net.Core.IPAddress
function Address:__init(id, domain, ipAddress)
    self.Id = id
    self.Domain = domain
    self.IPAddress = ipAddress
end

---@return Core.UUID id, string domain, Net.Core.IPAddress ipAddress
function Address:Serialize()
    return self.Id, self.Domain, self.IPAddress
end

return Utils.Class.Create(Address, "DNS.Entities.Address",
    require("Core.Json.Serializable"))
