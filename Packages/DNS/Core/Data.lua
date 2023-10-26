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
    JsonSerializer.Static__Serializer:AddTypeInfos({
        require("DNS.Core.Entities.Address.Address"):Static__GetType(),
        require("DNS.Core.Entities.Address.Create"):Static__GetType(),
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
]]
}

PackageData["DNSCoreEntitiesAddressCreate"] = {
    Location = "DNS.Core.Entities.Address.Create",
    Namespace = "DNS.Core.Entities.Address.Create",
    IsRunnable = true,
    Data = [[
---@class DNS.Core.Entities.Address.Create : Core.Json.Serializable
---@field Url string
---@field IPAddress Net.Core.IPAddress
---@overload fun(url: string, ipAddress: Net.Core.IPAddress) : DNS.Core.Entities.Address.Create
local Create = {}

---@private
---@param url string
---@param ipAddress Net.Core.IPAddress
function Create:__init(url, ipAddress)
    self.Url = url
    self.IPAddress = ipAddress
end

---@return string url, Net.Core.IPAddress ipAddress
function Create:Serialize()
    return self.Url, self.IPAddress
end

return Utils.Class.CreateClass(Create, "DNS.Entities.Address.Create",
    require("Core.Json.Serializable"))
]]
}

return PackageData
