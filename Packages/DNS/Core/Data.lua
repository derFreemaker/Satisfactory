local Data={
["DNS.Core.__events"] = [==========[
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

]==========],
["DNS.Core.Entities.Address.Address"] = [==========[
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

]==========],
["DNS.Core.Entities.Address.Create"] = [==========[
---@class DNS.Core.Entities.Address.Create : object, Core.Json.Serializable
---@field Domain string
---@field IPAddress Net.IPAddress
---@overload fun(domain: string, ipAddress: Net.IPAddress) : DNS.Core.Entities.Address.Create
local Create = {}

---@private
---@param domain string
---@param ipAddress Net.IPAddress
function Create:__init(domain, ipAddress)
    self.Domain = domain
    self.IPAddress = ipAddress
end

---@return string url, Net.IPAddress ipAddress
function Create:Serialize()
    return self.Domain, self.IPAddress
end

return class("DNS.Core.Entities.Address.Create", Create, { Inherit = require("Core.Json.Serializable") })

]==========],
}

return Data
