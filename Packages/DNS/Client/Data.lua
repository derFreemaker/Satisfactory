local PackageData = {}

-- ########## DNS.Client ##########

PackageData.MFYoiWSx = {
    Namespace = "DNS.Client.DNSClient",
    Name = "DNSClient",
    FullName = "DNSClient.lua",
    IsRunnable = true,
    Data = [[
local NetworkClient = require("Core.Net.NetworkClient")
local ApiClient = require("Core.RestApi.Client.RestApiNetworkClient")
local ApiRequest = require("Core.RestApi.RestApiRequest")

local Address = require("DNS.Core.Entities.Address.Address")
local CreateAddress = require("DNS.Core.Entities.Address.Create")


---@class DNS.Client : object
---@field private networkClient Core.Net.NetworkClient
---@field private apiClient Core.RestApi.Client.RestApiClient
---@field private logger Core.Logger
---@overload fun(networkClient: Core.Net.NetworkClient, logger: Core.Logger) : DNS.Client
local DNSClient = {}


---@private
---@param networkClient Core.Net.NetworkClient?
---@param logger Core.Logger
function DNSClient:__init(networkClient, logger)
    self.networkClient = networkClient or NetworkClient(logger:subLogger("NetworkClient"))
    self.logger = logger
end


---@param networkClient Core.Net.NetworkClient
---@return string id
function DNSClient:Static__GetServerAddress(networkClient)
    local netPort = networkClient:CreateNetworkPort(53)

    netPort:BroadCastMessage("GetDNSServerAddress", nil, nil)
    ---@type Core.Net.NetworkContext?
    local response
    local try = 0
    repeat
        try = try + 1
        response = netPort:WaitForEvent("ReturnDNSServerAddress", 10)
    until response ~= nil or try == 10
    if try == 10 then
        error("unable to get dns server address")
    end
    ---@cast response Core.Net.NetworkContext
    return response.Body
end


function DNSClient:GetDNSServerAddressIfNeeded()
    if self.apiClient then
        return
    end

    local serverIPAddress = self:Static__GetServerAddress(self.networkClient)
    self.apiClient = ApiClient(serverIPAddress, 80, 80, self.networkClient, self.logger:subLogger("ApiClient"))
end


---@param address string
---@param id string
---@return boolean success
function DNSClient:CreateAddress(address, id)
    self:GetDNSServerAddressIfNeeded()

    local createAddress = CreateAddress(address, id)

    local request = ApiRequest("CREATE", "Address", createAddress:ExtractData())
    local response = self.apiClient:request(request)

    if not response.WasSuccessfull then
        return false
    end
    return response.Body
end


---@param address string
---@return boolean success
function DNSClient:DeleteAddress(address)
    self:GetDNSServerAddressIfNeeded()

    local request = ApiRequest("DELETE", "Address", address)
    local response = self.apiClient:request(request)

    if not response.WasSuccessfull then
        return false
    end
    return response.Body
end


---@param address string
---@return DNS.Core.Entities.Address? address
function DNSClient:GetWithAddress(address)
    self:GetDNSServerAddressIfNeeded()

    local request = ApiRequest("GET", "AddressWithAddress", address)
    local response = self.apiClient:request(request)

    if not response.WasSuccessfull then
        return nil
    end
    return Address:Static__CreateFromData(response.Body)
end


---@param id string
---@return DNS.Core.Entities.Address? address
function DNSClient:GetWithId(id)
    self:GetDNSServerAddressIfNeeded()

    local request = ApiRequest("GET", "AddressWithId", id)
    local response = self.apiClient:request(request)

    if not response.WasSuccessfull then
        return nil
    end
    return Address:Static__CreateFromData(response.Body)
end


return Utils.Class.CreateClass(DNSClient, "DNS.Client")
]]
}

-- ########## DNS.Client ########## --

return PackageData
