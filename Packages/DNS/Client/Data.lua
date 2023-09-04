local PackageData = {}

-- ########## DNS.Client ##########

PackageData.MFYoiWSx = {
    Namespace = "DNS.Client.DNSClient",
    Name = "DNSClient",
    FullName = "DNSClient.lua",
    IsRunnable = true,
    Data = [[
local ApiClient = require("Core.RestApi.Client.RestApiNetworkClient")
local ApiRequest = require("Core.RestApi.RestApiRequest")
local Address = require("DNS.Core.Entities.Addresss.Address")
local CreateAddress = require("DNS.Core.Entities.Addresss.Create")
local DNSClient = {}
function DNSClient:__call(networkClient, logger)
    local serverIPAddress = self:Static__GetServerAddress(networkClient)
    self.apiClient = ApiClient(serverIPAddress, 80, 80, networkClient, logger:subLogger("ApiClient"))
    self.logger = logger
end
function DNSClient:Static__GetServerAddress(networkClient)
    local netPort = networkClient:CreateNetworkPort(53)
    netPort:BroadCastMessage("GetDNSServerAddress", nil, nil)

    local response
    repeat
        response = netPort:WaitForEvent("ReturnDNSServerAddress", 5)
    until response ~= nil

    return response.Body
end
function DNSClient:CreateAddress(address, id)
    local createAddress = CreateAddress(address, id)
    local request = ApiRequest("CREATE", "Address", createAddress:ExtractData())
    local response = self.apiClient:request(request)
    if not response.WasSuccessfull then
        return false
    end
    return response.Body
end
function DNSClient:DeleteAddress(address)
    local request = ApiRequest("DELETE", "Address", address)
    local response = self.apiClient:request(request)
    if not response.WasSuccessfull then
        return false
    end
    return response.Body
end
function DNSClient:GetWithAddress(address)
    local request = ApiRequest("GET", "AddressWithAddress", address)
    local response = self.apiClient:request(request)
    if not response.WasSuccessfull then
        return nil
    end
    return Address:Static__CreateFromData(response.Body)
end
function DNSClient:GetWithId(id)
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
