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

function HttpClient:Request(method, endpoint, )
    -- //TODO: process request
end

return Utils.Class.CreateClass(HttpClient, "Http.HttpClient")