local NetworkClient = require("Core.Net.NetworkClient")
local RestApiController = require("Core.RestApi.Server.RestApiController")
local AddressDatabase = require("DNS.Server.AddressDatabase")


---@class DNS.Endpoints : Core.RestApi.Server.RestApiEndpointBase
---@field private apiController Core.RestApi.Server.RestApiController
---@field private addressDatabase DNS.Server.AddressDatabase
---@field private logger Core.Logger
---@overload fun(netClient: Core.Net.NetworkClient, logger: Core.Logger) : DNS.Endpoints
local Endpoints = {}


---@private
---@param netClient Core.Net.NetworkClient
---@param logger Core.Logger
function Endpoints:__init(netClient, logger)
    logger:LogTrace("setting up DNS Server endpoints...")
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