---@class DNS.Core.Entities.Address : object, Core.Json.Serializable
---@field Id Core.UUID
---@field Domain string
---@field IPAddress Net.IPAddress
---@overload fun(id: Core.UUID, domain: string, ipAddress: Net.IPAddress) : DNS.Core.Entities.Address
local Address = {}

---@private
---@param id Core.UUID
---@param domain string
---@param ipAddress Net.IPAddress
function Address:__init(id, domain, ipAddress)
    self.Id = id
    self.Domain = domain
    self.IPAddress = ipAddress
end

---@return Core.UUID id, string domain, Net.IPAddress ipAddress
function Address:Serialize()
    return self.Id, self.Domain, self.IPAddress
end

return class("DNS.Core.Entities.Address", Address, { Inherit = require("Core.Json.Serializable") })
