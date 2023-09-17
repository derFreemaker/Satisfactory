local PackageData = {}

PackageData.AEMBAHeA = {
    Location = "Http.HttpClient",
    Namespace = "Http.HttpClient",
    IsRunnable = true,
    Data = [[
local NetworkClient = require("Net.Core.NetworkClient")
local DNSClient = require("DNS.Client.DNSClient")

---@class Http.HttpClient : object
---@field private netClient Core.Net.NetworkClient
---@field private dnsClient DNS.Client
---@field private logger Core.Logger
---@overload fun(logger: Core.Logger, dnsClient: DNS.Client, networkClient: Core.Net.NetworkClient?) : Http.HttpClient
local HttpClient = {}

---@param logger Core.Logger
---@param dnsClient DNS.Client
---@param networkClient Core.Net.NetworkClient?
function HttpClient:__init(logger, dnsClient, networkClient)
    self.netClient = networkClient or NetworkClient(logger:subLogger("NetworkClient"))
    self.dnsClient = dnsClient or DNSClient(self.netClient, logger:subLogger("DNSClient"))
    self.logger = logger
end

function HttpClient:Request(method, endpoint, body, header)
    -- //TODO: process request
end

return Utils.Class.CreateClass(HttpClient, "Http.HttpClient")
]]
}

PackageData.bTwMXABa = {
    Location = "Http.HttpRequest",
    Namespace = "Http.HttpRequest",
    IsRunnable = true,
    Data = [[
---@class Http.HttpRequest : object
---@field private Client Http.HttpClient
---@overload fun(client: Http.HttpClient) : Http.HttpRequest
local HttpRequest = {}

---@private
---@param client Http.HttpClient
function HttpRequest:__init(client)
    self.Client = client
end


function HttpRequest:Send()
    self.Client:Request()
end

-- //TODO: request

return Utils.Class.CreateClass(HttpRequest, "Http.HttpRequest")
]]
}

return PackageData
