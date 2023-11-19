---@meta
local PackageData = {}

PackageData["DNSCore__events"] = {
    Location = "DNS.Core.__events",
    Namespace = "DNS.Core.__events",
    IsRunnable = true,
    Data = [[
local JsonSerializer = require("Core.Json.JsonSerializer")

---@class DNS.Core.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    JsonSerializer.Static__Serializer:AddClasses({
        require("DNS.Core.Entities.Address.Address"),
        require("DNS.Core.Entities.Address.Create"),
    })
end

return Events
]]
}

PackageData["DNSCoreEntitiesAddressAddress"] = {
    Location = "DNS.Core.Entities.Address.Address",
    Namespace = "DNS.Core.Entities.Address.Address",
    IsRunnable = true,
    Data = [[
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

return Utils.Class.CreateClass(Address, "DNS.Entities.Address",
    require("Core.Json.Serializable"))
]]
}

PackageData["DNSCoreEntitiesAddressCreate"] = {
    Location = "DNS.Core.Entities.Address.Create",
    Namespace = "DNS.Core.Entities.Address.Create",
    IsRunnable = true,
    Data = [[
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
]]
}

return PackageData
