local AddressDatabase = require("DNS.Server.AddressDatabase")

---@class DNS.Endpoints : Net.Rest.Api.Server.EndpointBase
---@field private m_addressDatabase DNS.Server.AddressDatabase
---@overload fun(logger: Core.Logger, controller: Net.Rest.Api.Server.Controller) : DNS.Endpoints
local Endpoints = {}

---@private
---@param logger Core.Logger
---@param controller Net.Rest.Api.Server.Controller
---@param super fun(endpointLogger: Core.Logger, apiController: Net.Rest.Api.Server.Controller)
function Endpoints:__init(super, logger, controller)
    super(logger, controller)

    self.m_addressDatabase = AddressDatabase(logger:subLogger("AddressDatabase"))

    self:AddEndpoint("CREATE", "/Address/Create/", self.CreateAddress)
    self:AddEndpoint("DELETE", "/Address/{id:Core.UUID}/Delete/", self.DeletetAddress)
    self:AddEndpoint("GET", "/Address/Id/{id:Core.UUID}/", self.GetAddressWithId)
    self:AddEndpoint("GET", "/Address/Domain/{domian:string}/", self.GetAddressWithDomain)
end

---@param createAddress DNS.Core.Entities.Address.Create
---@return Net.Rest.Api.Response response
function Endpoints:CreateAddress(createAddress)
    local success = self.m_addressDatabase:Create(createAddress)

    return self.Templates:Ok(success)
end

---@param id Core.UUID
---@return Net.Rest.Api.Response response
function Endpoints:DeletetAddress(id)
    local success = self.m_addressDatabase:DeleteById(id)
    if not success then
        return self.Templates:NotFound("Unable to find address with given id")
    end

    return self.Templates:Ok(success)
end

---@param id Core.UUID
---@return Net.Rest.Api.Response response
function Endpoints:GetAddressWithId(id)
    local address = self.m_addressDatabase:GetWithId(id)
    if not address then
        return self.Templates:NotFound("Unable to find address with given id")
    end

    return self.Templates:Ok(address)
end

---@param addressStr string
---@return Net.Rest.Api.Response response
function Endpoints:GetAddressWithDomain(addressStr)
    local address = self.m_addressDatabase:GetWithDomain(addressStr)
    if not address then
        return self.Templates:NotFound("Unable to find address with given address")
    end

    return self.Templates:Ok(address)
end

return Utils.Class.CreateClass(Endpoints, "DNS.Server.Endpoints",
    require("Net.Rest.Api.Server.EndpointBase"))
