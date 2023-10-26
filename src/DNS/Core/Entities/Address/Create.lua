---@class DNS.Core.Entities.Address.Create : Core.Json.Serializable
---@field Domain string
---@field IPAddress Net.Core.IPAddress
---@overload fun(domain: string, ipAddress: Net.Core.IPAddress) : DNS.Core.Entities.Address.Create
local Create = {}

---@private
---@param domain string
---@param ipAddress Net.Core.IPAddress
function Create:__init(domain, ipAddress)
    self.Domain = domain
    self.IPAddress = ipAddress
end

---@return string url, Net.Core.IPAddress ipAddress
function Create:Serialize()
    return self.Domain, self.IPAddress
end

return Utils.Class.CreateClass(Create, "DNS.Entities.Address.Create",
    require("Core.Json.Serializable"))
