local PackageData = {}

-- ########## Http ##########

PackageData.MFYoiWSx = {
    Namespace = "Http.HttpClient",
    Name = "HttpClient",
    FullName = "HttpClient.lua",
    IsRunnable = true,
    Data = [[
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
    
end

return Utils.Class.CreateClass(HttpClient, "Http.HttpClient")
]]
}

PackageData.oVIzFPpX = {
    Namespace = "Http.HttpRequest",
    Name = "HttpRequest",
    FullName = "HttpRequest.lua",
    IsRunnable = true,
    Data = [[
---@class Http.HttpRequest : object
local HttpRequest = {}



return Utils.Class.CreateClass(HttpRequest, "Http.HttpRequest")
]]
}

-- ########## Http ########## --

return PackageData
