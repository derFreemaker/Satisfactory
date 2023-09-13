local NetworkClient = require("Net.Core.NetworkClient")
local DNSClient = require("DNS.Client.DNSClient")

---@class Http.HttpClient : object
---@field private netClient Core.Net.NetworkClient
---@field private logger Core.Logger
---@overload fun(logger: Core.Logger, networkClient: Core.Net.NetworkClient?) : Http.HttpClient
local HttpClient = {}

---@param logger Core.Logger
---@param networkClient Core.Net.NetworkClient?
function HttpClient:__init(logger, networkClient)
    self.netClient = networkClient or NetworkClient(logger:subLogger("NetworkClient"))
    self.logger = logger
end

---@param request Http.HttpRequest
function HttpClient:Request(request)
    -- //TODO: process request
end

return Utils.Class.CreateClass(HttpClient, "Http.HttpClient")