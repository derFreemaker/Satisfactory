local PackageData = {}

PackageData.QXwFxOcZ = {
    Location = "DNS.Server.AddressDatabase",
    Namespace = "DNS.Server.AddressDatabase",
    IsRunnable = true,
    Data = [[
local DbTable = require("Database.DbTable")
local Path = require("Core.Path")
local Address = require("DNS.Core.Entities.Address.Address")


---@class DNS.Server.AddressDatabase : object
---@field private dbTable Database.DbTable
---@overload fun(logger: Core.Logger) : DNS.Server.AddressDatabase
local AddressDatabase = {}


---@private
---@param logger Core.Logger
function AddressDatabase:__init(logger)
    self.dbTable = DbTable("Addresses", Path("/Database/Addresses.db"), logger:subLogger("DbTable"))
    self.dbTable:Load()
end


---@param createAddress DNS.Core.Entities.Address.Create
---@return boolean
function AddressDatabase:Create(createAddress)
    if self:GetWithId(createAddress.Id) then
        return false
    end
    local address = Address:Static__CreateFromCreateAddress(createAddress)
    self.dbTable:Set(address.Id, address:ExtractData())
    return true
end


---@param addressAddress string
---@return boolean
function AddressDatabase:Delete(addressAddress)
    local address = self:GetWithAddress(addressAddress)
    if not address then
        return false
    end
    self.dbTable:Delete(address.Id)
    return true
end


---@param id string
---@return DNS.Core.Entities.Address? address
function AddressDatabase:GetWithId(id)
    for addressId, data in pairs(self.dbTable) do
        if addressId == id then
            return Address:Static__CreateFromData(data)
        end
    end
end


---@param addressAddress string
---@return DNS.Core.Entities.Address? createAddress
function AddressDatabase:GetWithAddress(addressAddress)
    for _, data in pairs(self.dbTable) do
        local address = Address:Static__CreateFromData(data)
        if address.Address == addressAddress then
            return address
        end
    end
end


return Utils.Class.CreateClass(AddressDatabase, "DNS.Server.AddressDatabase")
]]
}

PackageData.rmhQUIAz = {
    Location = "DNS.Server.Endpoints",
    Namespace = "DNS.Server.Endpoints",
    IsRunnable = true,
    Data = [[
local AddressDatabase = require("DNS.Server.AddressDatabase")
local AddressEntities = {
    Create = require("DNS.Core.Entities.Address.Create")
}

---@class DNS.Endpoints : Net.Rest.Api.Server.EndpointBase
---@field private addressDatabase DNS.Server.AddressDatabase
---@field private logger Core.Logger
---@overload fun(logger: Core.Logger) : DNS.Endpoints
local Endpoints = {}


---@private
---@param logger Core.Logger
function Endpoints:__init(logger)
    self.addressDatabase = AddressDatabase(logger:subLogger("AddressDatabase"))
    self.logger = logger
end


---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function Endpoints:CREATE__Address(request)
    ---@type DNS.Core.Entities.Address.Create
    local createAddress = AddressEntities.Create:Static__CreateFromData(request.Body)

    local success = self.addressDatabase:Create(createAddress)
    return self.Templates:Ok(success)
end


---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function Endpoints:DELETE__Address(request)
    local success = self.addressDatabase:Delete(request.Body)
    if not success then
        return self.Templates:NotFound("Unable to find address with given id")
    end
    return self.Templates:Ok(success)
end


---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function Endpoints:GET__AddressWithAddress(request)
    local address = self.addressDatabase:GetWithAddress(request.Body)
    if not address then
        return self.Templates:NotFound("Unable to find address with given address")
    end
    return self.Templates:Ok(address:ExtractData())
end


---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function Endpoints:GET__AddressWithId(request)
    local address = self.addressDatabase:GetWithId(request.Body)
    if not address then
        return self.Templates:NotFound("Unable to find address with given id")
    end
    return self.Templates:Ok(address:ExtractData())
end


return Utils.Class.CreateClass(Endpoints, "DNS.Server.Endpoints", require("Net.Rest.RestApii.Server.RestApiEndpointBase"))
]]
}

PackageData.SBRbsBXZ = {
    Location = "DNS.Server.__main",
    Namespace = "DNS.Server.__main",
    IsRunnable = true,
    Data = [[
local DNSEndpoints = require("DNS.Server.Endpoints")
local NetworkClient = require("Net.Core.NetworkClient")
local Task = require("Core.Task")
local RestApiController = require("Net.Rest.RestApii.Server.RestApiController")

---@class DNS.Main : Github_Loading.Entities.Main
---@field private eventPullAdapter Core.EventPullAdapter
---@field private apiController Net.Rest.Api.Server.Controller
---@field private netPort Core.Net.NetworkPort
---@field private endpoints DNS.Endpoints
local Main = {}

---@param context Core.Net.NetworkContext
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
    self.Logger:LogDebug("setup Get DNS Server IP Address")

    self.Logger:LogTrace("setting up DNS Server endpoints...")
    local endpointLogger = self.Logger:subLogger("Endpoints")
    local netPort = netClient:CreateNetworkPort(80)
    self.apiController = RestApiController(netPort, endpointLogger:subLogger("ApiController"))
    self.endpoints = DNSEndpoints(endpointLogger)
    self.apiController:AddRestApiEndpointBase(self.endpoints)
    netPort:OpenPort()
    self.Logger:LogDebug("setup DNS Server endpoints")
end

function Main:Run()
    self.Logger:LogInfo("started DNS Server")
    self.eventPullAdapter:Run()
end

return Main
]]
}

return PackageData
