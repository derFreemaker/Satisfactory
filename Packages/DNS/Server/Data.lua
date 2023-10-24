---@meta
local PackageData = {}

PackageData["DNSServer__main"] = {
    Location = "DNS.Server.__main",
    Namespace = "DNS.Server.__main",
    IsRunnable = true,
    Data = [[
local Usage = require("Core.Usage.Usage")

local Task = require('Core.Task')

local Host = require("Hosting.Host")

local DNSEndpoints = require('DNS.Server.Endpoints')

---@class DNS.Main : Github_Loading.Entities.Main
---@field private _NetClient Net.Core.NetworkClient
---@field private _Host Hosting.Host
local Main = {}

---@param context Net.Core.NetworkContext
function Main:GetDNSServerAddress(context)
	local id = self._NetClient:GetIPAddress():GetAddress()
	self.Logger:LogDebug(context.SenderIPAddress, 'requested DNS Server IP Address')
	self._NetClient:Send(context.SenderIPAddress, Usage.Ports.DNS, Usage.Events.DNS_ReturnServerAddress, id)
end

function Main:Configure()
	self._Host = Host(self.Logger:subLogger("Host"), "DNS")

	self._Host:AddCallableEvent(Usage.Events.DNS_GetServerAddress, Usage.Ports.DNS,
		Task(self.GetDNSServerAddress, self))
	self.Logger:LogDebug('setup Get DNS Server IP Address')

	self._Host:AddEndpoint(Usage.Ports.DNS, "Endpoints", DNSEndpoints --{{{@as Net.Rest.Api.Server.EndpointBase}}})
	self.Logger:LogDebug('setup DNS Server endpoints')

	self._NetClient = self._Host:GetNetworkClient()
end

function Main:Run()
	self._Host:Ready()
	while true do
		self._NetClient:BroadCast(Usage.Ports.Heartbeats, 'DNS')
		self._Host:RunCycle(20)
	end
end

return Main
]]
}

PackageData["DNSServerAddressDatabase"] = {
    Location = "DNS.Server.AddressDatabase",
    Namespace = "DNS.Server.AddressDatabase",
    IsRunnable = true,
    Data = [[
local DbTable = require("Database.DbTable")
local Path = require("Core.FileSystem.Path")
local Address = require("DNS.Core.Entities.Address.Address")

local UUID = require("Core.UUID")

---@class DNS.Server.AddressDatabase : object
---@field private _DbTable Database.DbTable | Dictionary<Core.UUID, DNS.Core.Entities.Address>
---@overload fun(logger: Core.Logger) : DNS.Server.AddressDatabase
local AddressDatabase = {}

---@private
---@param logger Core.Logger
function AddressDatabase:__init(logger)
    self._DbTable = DbTable("Addresses", Path("/Database/Addresses/"), logger:subLogger("DbTable"))
    self._DbTable:Load()
end

---@param createAddress DNS.Core.Entities.Address.Create
---@return boolean
function AddressDatabase:Create(createAddress)
    if self:GetWithUrl(createAddress.Url) then
        return false
    end

    local address = Address(UUID.Static__New(), createAddress.Url, createAddress.IPAddress)
    self._DbTable:Set(address.Id, address)

    self._DbTable:Save()
    return true
end

---@param id Core.UUID
---@return boolean
function AddressDatabase:DeleteById(id)
    self._DbTable:Delete(id)

    self._DbTable:Save()
    return true
end

---@param addressAddress string
---@return boolean
function AddressDatabase:DeleteByUrl(addressAddress)
    local address = self:GetWithUrl(addressAddress)
    if not address then
        return false
    end

    self._DbTable:Delete(address.Id)

    self._DbTable:Save()
    return true
end

---@param addressId Core.UUID
---@return DNS.Core.Entities.Address? address
function AddressDatabase:GetWithId(addressId)
    for id, address in pairs(self._DbTable) do
        if id == addressId then
            return address
        end
    end
end

---@param addressAddress string
---@return DNS.Core.Entities.Address? createAddress
function AddressDatabase:GetWithUrl(addressAddress)
    for _, address in pairs(self._DbTable) do
        if address.Url == addressAddress then
            return address
        end
    end
end

return Utils.Class.CreateClass(AddressDatabase, "DNS.Server.AddressDatabase")
]]
}

PackageData["DNSServerEndpoints"] = {
    Location = "DNS.Server.Endpoints",
    Namespace = "DNS.Server.Endpoints",
    IsRunnable = true,
    Data = [[
local AddressDatabase = require("DNS.Server.AddressDatabase")

---@class DNS.Endpoints : Net.Rest.Api.Server.EndpointBase
---@field private _AddressDatabase DNS.Server.AddressDatabase
---@overload fun(logger: Core.Logger, controller: Net.Rest.Api.Server.Controller) : DNS.Endpoints
local Endpoints = {}

---@private
---@param logger Core.Logger
---@param controller Net.Rest.Api.Server.Controller
---@param baseFunc fun(endpointLogger: Core.Logger, apiController: Net.Rest.Api.Server.Controller)
function Endpoints:__init(baseFunc, logger, controller)
    baseFunc(logger, controller)

    self._AddressDatabase = AddressDatabase(logger:subLogger("AddressDatabase"))

    self:AddEndpoint("CREATE", "/Address/Create", self.CreateAddress)
    self:AddEndpoint("DELETE", "/Address/{id:Core.UUID}/Delete", self.DeletetAddress)
    self:AddEndpoint("GET", "/Address/Id/{id:Core.UUID}/", self.GetAddressWithId)
    self:AddEndpoint("GET", "Address/Url/{url:string}", self.GetAddressWithAddress)
end

---@param createAddress DNS.Core.Entities.Address.Create
---@return Net.Rest.Api.Response response
function Endpoints:CreateAddress(createAddress)
    local success = self._AddressDatabase:Create(createAddress)

    return self.Templates:Ok(success)
end

---@param id Core.UUID
---@return Net.Rest.Api.Response response
function Endpoints:DeletetAddress(id)
    local success = self._AddressDatabase:DeleteById(id)
    if not success then
        return self.Templates:NotFound("Unable to find address with given id")
    end

    return self.Templates:Ok(success)
end

---@param id Core.UUID
---@return Net.Rest.Api.Response response
function Endpoints:GetAddressWithId(id)
    local address = self._AddressDatabase:GetWithId(id)
    if not address then
        return self.Templates:NotFound("Unable to find address with given id")
    end

    return self.Templates:Ok(address)
end

---@param addressStr string
---@return Net.Rest.Api.Response response
function Endpoints:GetAddressWithAddress(addressStr)
    local address = self._AddressDatabase:GetWithUrl(addressStr)
    if not address then
        return self.Templates:NotFound("Unable to find address with given address")
    end

    return self.Templates:Ok(address)
end

return Utils.Class.CreateClass(Endpoints, "DNS.Server.Endpoints",
    require("Net.Rest.Api.Server.EndpointBase") --{{{@as Net.Rest.Api.Server.EndpointBase}}})
]]
}

return PackageData
