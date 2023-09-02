local ApiClient = require("Core.RestApi.Client.RestApiNetworkClient")
local ApiRequest = require("Core.RestApi.RestApiRequest")

local Address = require("DNS.Core.Entities.Addresss.Address")
local CreateAddress = require("DNS.Core.Entities.Addresss.Create")


---@class DNS.Client : object
---@field private apiClient Core.RestApi.Client.RestApiClient
---@field private logger Core.Logger
local DNSClient = {}


---@param networkClient Core.Net.NetworkClient
---@param logger Core.Logger
function DNSClient:__call(networkClient, logger)
    local serverIPAddress = self:Static__GetServerAddress(networkClient)
    self.apiClient = ApiClient(serverIPAddress, 80, 80, networkClient, logger:subLogger("ApiClient"))

    self.logger = logger
end


---@param networkClient Core.Net.NetworkClient
---@return string id
function DNSClient:Static__GetServerAddress(networkClient)
    local netPort = networkClient:CreateNetworkPort(53)

    netPort:BroadCastMessage("GetDNSServerAddress", nil, nil)
    ---@type Core.Net.NetworkContext?
    local response
    repeat
        response = netPort:WaitForEvent("ReturnDNSServerAddress", 5)
    until response ~= nil
    ---@cast response Core.Net.NetworkContext
    return response.Body
end


---@param address string
---@param id string
---@return boolean success
function DNSClient:CreateAddress(address, id)
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
    local request = ApiRequest("GET", "AddressWithId", id)
    local response = self.apiClient:request(request)

    if not response.WasSuccessfull then
        return nil
    end
    return Address:Static__CreateFromData(response.Body)
end


return Utils.Class.CreateClass(DNSClient, "DNS.Client")