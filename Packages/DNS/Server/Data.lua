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


---@class DNS.Server.AddressDatabase : object
---@field private dbTable Database.DbTable
---@overload fun(logger: Core.Logger) : DNS.Server.AddressDatabase
local AddressDatabase = {}


---@private
---@param logger Core.Logger
function AddressDatabase:__init(logger)
    self.dbTable = DbTable("Addresses", Path("/Database/Addresses.db"), logger:subLogger("DbTable"))
end


---@param createAddress DNS.Core.Entities.Address.Create
---@return boolean
function AddressDatabase:Create(createAddress)
    if self:GetWithId(createAddress.Id) then
        return false
    end
    local address = Address:Static__CreateFromCreateAddress(createAddress)
    self.dbTable:Set(address.Id, address)
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
    for addressId, address in pairs(self.dbTable) do
        ---@cast address DNS.Core.Entities.Address
        if addressId == id then
            return address
        end
    end
end


---@param addressAddress string
---@return DNS.Core.Entities.Address? createAddress
function AddressDatabase:GetWithAddress(addressAddress)
    for _, address in pairs(self.dbTable) do
        ---@cast address DNS.Core.Entities.Address
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


---@class DNS.Endpoints : Core.RestApi.Server.RestApiEndpointBase
---@field private apiController Core.RestApi.Server.RestApiController
---@field private addressDatabase DNS.Server.AddressDatabase
---@field private logger Core.Logger
---@overload fun(logger: Core.Logger) : DNS.Endpoints
local Endpoints = {}


---@private
---@param logger Core.Logger
function Endpoints:__init(logger)
    logger:LogTrace("setting up DNS Server endpoints...")
    local netClient = NetworkClient(logger:subLogger("NetworkClient"))
    local netPort = netClient:CreateNetworkPort(80)
    self.apiController = RestApiController(netPort, logger:subLogger("ApiController"))
    self.addressDatabase = AddressDatabase(logger:subLogger("AddressDatabase"))

    self.apiController:AddRestApiEndpointBase(self)
    self.logger = logger
    netPort:OpenPort()
    logger:LogDebug("setup DNS Server endpoints")
end


---@param request Core.RestApi.RestApiRequest
---@return Core.RestApi.RestApiResponse response
function Endpoints:CREATE__Address(request)
    ---@type DNS.Core.Entities.Address.Create
    local createAddress = require("src.DNS.Entities.Address.Create"):Static__CreateFromData(request.Body)

    local success = self.addressDatabase:Create(createAddress)
    return self.Templates:Ok(success)
end


---@param request Core.RestApi.RestApiRequest
---@return Core.RestApi.RestApiResponse response
function Endpoints:DELETE__Address(request)
    local success = self.addressDatabase:Delete(request.Body)
    if not success then
        return self.Templates:NotFound("Unable to find address with given id")
    end
    return self.Templates:Ok(success)
end


---@param request Core.RestApi.RestApiRequest
---@return Core.RestApi.RestApiResponse response
function Endpoints:GET__AddressWithAddress(request)
    local address = self.addressDatabase:GetWithAddress(request.Body)
    if not address then
        return self.Templates:NotFound("Unable to find address with given address")
    end
    return self.Templates:Ok(address:ExtractData())
end


---@param request Core.RestApi.RestApiRequest
---@return Core.RestApi.RestApiResponse response
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

---@class DNS.Main : Github_Loading.Entities.Main
---@field private eventPullAdapter Core.EventPullAdapter
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
    self.Logger:LogDebug("setup get DNS Server IP Address")

    self.endpoints = DNSEndpoints(self.Logger:subLogger("Endpoints"))
end

function Main:Run()
    self.Logger:LogInfo("started DNS Server")
    self.eventPullAdapter:Run()
end

return Main
]]
}

-- ########## DNS.Server ########## --

return PackageData
