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
	self.Logger:LogDebug(context.SenderIPAddress .. ' requested DNS Server IP Address')
	self._NetClient:Send(context.SenderIPAddress, Usage.Ports.DNS, Usage.Events.DNS_ReturnServerAddress, id)
end

function Main:Configure()
	self._Host = Host(self.Logger:subLogger("Host"), "DNS")

	self._Host:AddCallableEvent("GetDNSServerAddress", Usage.Ports.DNS, Task(self.GetDNSServerAddress, self))
	self.Logger:LogDebug('setup Get DNS Server IP Address')

	local endpointLogger = self.Logger:subLogger("Endpoints")
	self._Host:AddEndpointBase(Usage.Ports.HTTP, endpointLogger, DNSEndpoints(endpointLogger))
	self.Logger:LogDebug('setup DNS Server endpoints')

	self._NetClient = self._Host:GetNetworkClient()
end

function Main:Run()
	self._Host:Ready()
	while true do
		self._NetClient:BroadCast(Usage.Ports.Heartbeats, 'DNS')
		self._Host:RunCycle(3)
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


---@class DNS.Server.AddressDatabase : object
---@field private _DbTable Database.DbTable
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
    if self:GetWithId(createAddress.Id) then
        return false
    end
    local address = Address:Static__CreateFromCreateAddress(createAddress)
    self._DbTable:Set(address.Id, address:ExtractData())

    self._DbTable:Save()
    return true
end

---@param addressAddress string
---@return boolean
function AddressDatabase:Delete(addressAddress)
    local address = self:GetWithAddress(addressAddress)
    if not address then
        return false
    end
    self._DbTable:Delete(address.Id)

    self._DbTable:Save()
    return true
end

---@param id string
---@return DNS.Core.Entities.Address? address
function AddressDatabase:GetWithId(id)
    for addressId, data in pairs(self._DbTable) do
        if addressId == id then
            return Address:Static__CreateFromData(data)
        end
    end
end

---@param addressAddress string
---@return DNS.Core.Entities.Address? createAddress
function AddressDatabase:GetWithAddress(addressAddress)
    for _, data in pairs(self._DbTable) do
        local address = Address:Static__CreateFromData(data)
        if address.Address == addressAddress then
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
local AddressEntities = {
    Create = require("DNS.Core.Entities.Address.Create")
}

---@class DNS.Endpoints : Net.Rest.Api.Server.EndpointBase
---@field private _AddressDatabase DNS.Server.AddressDatabase
---@field private _Logger Core.Logger
---@overload fun(logger: Core.Logger) : DNS.Endpoints
local Endpoints = {}

---@private
---@param logger Core.Logger
function Endpoints:__init(logger)
    self._AddressDatabase = AddressDatabase(logger:subLogger("AddressDatabase"))
    self._Logger = logger
end

---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function Endpoints:CREATE__Address(request)
    ---@type DNS.Core.Entities.Address.Create
    local createAddress = AddressEntities.Create:Static__CreateFromData(request.Body)

    local success = self._AddressDatabase:Create(createAddress)
    return self.Templates:Ok(success)
end

---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function Endpoints:DELETE__Address(request)
    local success = self._AddressDatabase:Delete(request.Body)
    if not success then
        return self.Templates:NotFound("Unable to find address with given id")
    end
    return self.Templates:Ok(success)
end

---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function Endpoints:GET__AddressWithAddress(request)
    local address = self._AddressDatabase:GetWithAddress(request.Body)
    if not address then
        return self.Templates:NotFound("Unable to find address with given address")
    end
    return self.Templates:Ok(address:ExtractData())
end

---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function Endpoints:GET__AddressWithId(request)
    local address = self._AddressDatabase:GetWithId(request.Body)
    if not address then
        return self.Templates:NotFound("Unable to find address with given id")
    end
    return self.Templates:Ok(address:ExtractData())
end

return Utils.Class.CreateClass(Endpoints, "DNS.Server.Endpoints", require("Net.Rest.Api.Server.EndpointBase"))
]]
}

return PackageData
