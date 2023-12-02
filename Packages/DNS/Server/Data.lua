---@meta
local PackageData = {}

PackageData["DNSServer__main"] = {
    Location = "DNS.Server.__main",
    Namespace = "DNS.Server.__main",
    IsRunnable = true,
    Data = [[
local Usage = require("Core.Usage.init")

local Task = require('Core.Common.Task')

local Host = require("Hosting.Host")

local DNSEndpoints = require('DNS.Server.Endpoints')

---@class DNS.Main : Github_Loading.Entities.Main
---@field private m_netClient Net.Core.NetworkClient
---@field private m_host Hosting.Host
local Main = {}

---@param context Net.Core.NetworkContext
function Main:GetDNSServerAddress(context)
	local id = self.m_netClient:GetIPAddress():GetAddress()
	self.Logger:LogDebug(context.SenderIPAddress:GetAddress(), 'requested DNS Server IP Address')
	self.m_netClient:Send(context.SenderIPAddress, Usage.Ports.DNS, Usage.Events.DNS_ReturnServerAddress, id)
end

function Main:Configure()
	self.m_host = Host(self.Logger:subLogger("Host"), "DNS Server")

	self.m_host:AddCallableEventListener(Usage.Events.DNS_GetServerAddress, Usage.Ports.DNS,
		self.GetDNSServerAddress, self)
	self.Logger:LogDebug('setup Get DNS Server IP Address')

	self.m_host:AddEndpoint(Usage.Ports.HTTP, "Endpoints", DNSEndpoints)
	self.Logger:LogDebug('setup DNS Server endpoints')

	self.m_netClient = self.m_host:GetNetworkClient()
end

function Main:Run()
	self.m_host:Ready()
	while true do
		self.m_netClient:BroadCast(Usage.Ports.DNS_Heartbeat, 'DNS')
		self.m_host:RunCycle(3)
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

local UUID = require("Core.Common.UUID")

---@class DNS.Server.AddressDatabase : object
---@field private m_dbTable Database.DbTable | table<string, DNS.Core.Entities.Address>
---@overload fun(logger: Core.Logger) : DNS.Server.AddressDatabase
local AddressDatabase = {}

---@private
---@param logger Core.Logger
function AddressDatabase:__init(logger)
    self.m_dbTable = DbTable("Addresses", Path("/Database/Addresses/"), logger:subLogger("DbTable"))
    self.m_dbTable:Load()
end

---@param createAddress DNS.Core.Entities.Address.Create
---@return boolean
function AddressDatabase:Create(createAddress)
    if self:GetWithDomain(createAddress.Domain) then
        return false
    end

    local address = Address(UUID.Static__New(), createAddress.Domain, createAddress.IPAddress)
    self.m_dbTable:Set(address.Id:ToString(), address)

    self.m_dbTable:Save()
    return true
end

---@param id Core.UUID
---@return boolean
function AddressDatabase:DeleteById(id)
    self.m_dbTable:Delete(id:ToString())

    self.m_dbTable:Save()
    return true
end

---@param addressAddress string
---@return boolean
function AddressDatabase:DeleteByUrl(addressAddress)
    local address = self:GetWithDomain(addressAddress)
    if not address then
        return false
    end

    self.m_dbTable:Delete(address.Id:ToString())

    self.m_dbTable:Save()
    return true
end

---@param addressId Core.UUID
---@return DNS.Core.Entities.Address? address
function AddressDatabase:GetWithId(addressId)
    for id, address in pairs(self.m_dbTable) do
        if id == addressId:ToString() then
            return address
        end
    end
end

---@param addressAddress string
---@return DNS.Core.Entities.Address? createAddress
function AddressDatabase:GetWithDomain(addressAddress)
    for _, address in pairs(self.m_dbTable) do
        if address.Domain == addressAddress then
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
---@field private m_addressDatabase DNS.Server.AddressDatabase
---@overload fun(logger: Core.Logger, controller: Net.Rest.Api.Server.Controller) : DNS.Endpoints
local Endpoints = {}

---@private
---@param logger Core.Logger
---@param controller Net.Rest.Api.Server.Controller
---@param super fun(endpointLogger: Core.Logger, apiController: Net.Rest.Api.Server.Controller)
function Endpoints:__init(super, logger, controller)
    super(logger, controller)

    self.m_addressDatabase = AddressDatabase(logger:subLogger("AddressDatabase"))

    self:AddEndpoint("CREATE", "/Address/Create/", self.CreateAddress)
    self:AddEndpoint("DELETE", "/Address/{id:Core.UUID}/Delete/", self.DeleteAddress)
    self:AddEndpoint("GET", "/Address/Id/{id:Core.UUID}/", self.GetAddressWithId)
    self:AddEndpoint("GET", "/Address/Domain/{domain:string}/", self.GetAddressWithDomain)
end

---@param createAddress DNS.Core.Entities.Address.Create
---@return Net.Rest.Api.Response response
function Endpoints:CreateAddress(createAddress)
    local success = self.m_addressDatabase:Create(createAddress)

    return self.Templates:Ok(success)
end

---@param id Core.UUID
---@return Net.Rest.Api.Response response
function Endpoints:DeleteAddress(id)
    local success = self.m_addressDatabase:DeleteById(id)
    if not success then
        return self.Templates:NotFound("Unable to find address with given id")
    end

    return self.Templates:Ok(success)
end

---@param id Core.UUID
---@return Net.Rest.Api.Response response
function Endpoints:GetAddressWithId(id)
    local address = self.m_addressDatabase:GetWithId(id)
    if not address then
        return self.Templates:NotFound("Unable to find address with given id")
    end

    return self.Templates:Ok(address)
end

---@param addressStr string
---@return Net.Rest.Api.Response response
function Endpoints:GetAddressWithDomain(addressStr)
    local address = self.m_addressDatabase:GetWithDomain(addressStr)
    if not address then
        return self.Templates:NotFound("Unable to find address with given address")
    end

    return self.Templates:Ok(address)
end

return Utils.Class.CreateClass(Endpoints, "DNS.Server.Endpoints",
    require("Net.Rest.Api.Server.EndpointBase"))
]]
}

return PackageData
