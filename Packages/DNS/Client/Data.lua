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
    self.networkClient = networkClient
    self.logger = logger
end
function DNSClient:Static__GetServerAddress(networkClient)
    local netPort = networkClient:CreateNetworkPort(53)
    netPort:BroadCastMessage("GetDNSServerAddress", nil, nil)

    local response
    local try
    repeat
        try = try + 1
        response = netPort:WaitForEvent("ReturnDNSServerAddress", 10)
    until response ~= nil or try == 10
    if try == 10 then
        error("unable to get dns server address")
    end

    return response.Body
end
function DNSClient:Check()
    if self.apiClient then
        return
    end
    local serverIPAddress = self:Static__GetServerAddress(self.networkClient)
    self.apiClient = ApiClient(serverIPAddress, 80, 80, self.networkClient, self.logger:subLogger("ApiClient"))
end
function DNSClient:CreateAddress(address, id)
    self:Check()
    local createAddress = CreateAddress(address, id)
    local request = ApiRequest("CREATE", "Address", createAddress:ExtractData())
    local response = self.apiClient:request(request)
    if not response.WasSuccessfull then
        return false
    end
    return response.Body
end
function DNSClient:DeleteAddress(address)
    self:Check()
    local request = ApiRequest("DELETE", "Address", address)
    local response = self.apiClient:request(request)
    if not response.WasSuccessfull then
        return false
    end
    return response.Body
end
function DNSClient:GetWithAddress(address)
    self:Check()
    local request = ApiRequest("GET", "AddressWithAddress", address)
    local response = self.apiClient:request(request)
    if not response.WasSuccessfull then
        return nil
    end
    return Address:Static__CreateFromData(response.Body)
end
function DNSClient:GetWithId(id)
    self:Check()
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
