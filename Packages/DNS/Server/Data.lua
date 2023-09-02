local PackageData = {}

-- ########## DNS.Server ##########

PackageData.MFYoiWSx = {
    Namespace = "DNS.Server.AddressDatabase",
    Name = "AddressDatabase",
    FullName = "AddressDatabase.lua",
    IsRunnable = true,
    Data = [[
local DbTable = require("Database.DbTable")
local Path = require("Core.Path")
local Address = require("DNS.Core.Entities.Address.Address")
local AddressDatabase = {}
function AddressDatabase:__call(logger)
    self.dbTable = DbTable("Addresses", Path("/Database/Addresses.db"), logger:subLogger("DbTable"))
end
function AddressDatabase:Create(createAddress)
    if self:GetWithId(createAddress.Id) then
        return false
    end
    local address = Address:Static__CreateFromCreateAddress(createAddress)
    self.dbTable:Set(address.Id, address)
    return true
end
function AddressDatabase:Delete(addressAddress)
    local address = self:GetWithAddress(addressAddress)
    if not address then
        return false
    end
    self.dbTable:Delete(address.Id)
    return true
end
function AddressDatabase:GetWithId(id)
    for addressId, address in pairs(self.dbTable) do

        if addressId == id then
            return address
        end
    end
end
function AddressDatabase:GetWithAddress(addressAddress)
    for _, address in pairs(self.dbTable) do

        if address.Address == addressAddress then
            return address
        end
    end
end
return Utils.Class.CreateClass(AddressDatabase, "DNS.Server.AddressDatabase")
]]
}

PackageData.oVIzFPpX = {
    Namespace = "DNS.Server.Endpoints",
    Name = "Endpoints",
    FullName = "Endpoints.lua",
    IsRunnable = true,
    Data = [[
local NetworkClient = require("Core.Net.NetworkClient")
local RestApiController = require("Core.RestApi.Server.RestApiController")
local AddressDatabase = require("DNS.Server.AddressDatabase")
local Endpoints = {}
function Endpoints:__call(logger)
    local netClient = NetworkClient(logger:subLogger("NetworkClient"))
    local netPort = netClient:CreateNetworkPort(80)
    self.apiController = RestApiController(netPort, logger:subLogger("ApiController"))
    self.addressDatabase = AddressDatabase(logger:subLogger("AddressDatabase"))
    self.apiController:AddRestApiEndpointBase(self)
    self.logger = logger
    netPort:OpenPort()
    logger:LogDebug("setup DNS Server endpoints")
end
function Endpoints:CREATE__Address(request)

    local createAddress = require("src.DNS.Entities.Address.Create"):Static__CreateFromData(request.Body)
    local success = self.addressDatabase:Create(createAddress)
    return self.Templates:Ok(success)
end
function Endpoints:DELETE__Address(request)
    local success = self.addressDatabase:Delete(request.Body)
    if not success then
        return self.Templates:NotFound("Unable to find address with given id")
    end
    return self.Templates:Ok(success)
end
function Endpoints:GET__AddressWithAddress(request)
    local address = self.addressDatabase:GetWithAddress(request.Body)
    if not address then
        return self.Templates:NotFound("Unable to find address with given address")
    end
    return self.Templates:Ok(address:ExtractData())
end
function Endpoints:GET__AddressWithId(request)
    local address = self.addressDatabase:GetWithId(request.Body)
    if not address then
        return self.Templates:NotFound("Unable to find address with given id")
    end
    return self.Templates:Ok(address:ExtractData())
end
return Utils.Class.CreateClass(Endpoints, "DNS.Server.Endpoints", require("Core.RestApi.Server.RestApiEndpointBase"))
]]
}

PackageData.PksKdJNx = {
    Namespace = "DNS.Server.__main",
    Name = "__main",
    FullName = "__main.lua",
    IsRunnable = true,
    Data = [[
local DNSEndpoints = require("DNS.Server.Endpoints")
local NetworkClient = require("Core.Net.NetworkClient")
local Task = require("Core.Task")
local Main = {}
function Main:GetDNSServerAddress(context)
    local netClient = self.netPort:GetNetClient()
    local id = netClient:GetId()
    self.Logger:LogDebug(context.SenderIPAddress .. " requested DNS Server IP Address")
    netClient:SendMessage(context.SenderIPAddress, 53, "ReturnDNSServerAddress", id)
end
function Main:Configure()
    self.eventPullAdapter = require("Core.Event.EventPullAdapter"):Initialize(self.Logger:subLogger("EventPullAdapter"))
    local dnsLogger = self.Logger:subLogger("DNSServerAddress")
    local netClient = NetworkClient(dnsLogger:subLogger("NetworkClient"))
    self.netPort = netClient:CreateNetworkPort(53)
    self.netPort:AddListener("GetDNSServerAddress", Task(self.GetDNSServerAddress, self))
    self.netPort:OpenPort()
    self.Logger:LogDebug("setup get DNS Server IP Address")
    self.endpoints = DNSEndpoints(self.Logger:subLogger("Endpoints"))
end
function Main:Run()
    self.eventPullAdapter:Run()
end
return Main
]]
}

-- ########## DNS.Server ########## --

return PackageData
