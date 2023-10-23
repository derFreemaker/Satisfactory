local AddressDatabase = require("DNS.Server.AddressDatabase")
local AddressEntities = {
    Create = require("DNS.Core.Entities.Address.Create")
}

---@class DNS.Endpoints : Net.Rest.Api.Server.EndpointBase
---@field private _AddressDatabase DNS.Server.AddressDatabase
---@overload fun(logger: Core.Logger, controller: Net.Rest.Api.Server.Controller) : DNS.Endpoints
local Endpoints = {}

---@private
---@param logger Core.Logger
---@param controller Net.Rest.Api.Server.Controller
---@param baseFunc fun(endpointLogger: Core.Logger, apiController: Net.Rest.Api.Server.Controller)
function Endpoints:__init(baseFunc, logger, controller)
    baseFunc(logger, controller)

    self._AddressDatabase = AddressDatabase(logger:subLogger("AddressDatabase"))

    self:AddEndpoint("GET", "/Address/Create", self.CreateAddress)
    self:AddEndpoint("DELETE", "/Address/{id:Core.UUID}/Delete", self.DeletetAddress)
    self:AddEndpoint("GET", "/Address/Id/{id:Core.UUID}/", self.GetAddressWithId)
    self:AddEndpoint("GET", "Address/Address/{address:string}", self.GetAddressWithAddress)
end

---@param createAddress DNS.Core.Entities.Address.Create
---@return Net.Rest.Api.Response response
function Endpoints:CreateAddress(createAddress)
    local success = self._AddressDatabase:Create(createAddress)

    return self.Templates:Ok(success)
end

---@param id Core.UUID
---@return Net.Rest.Api.Response response
function Endpoints:DeletetAddress(id)
    local success = self._AddressDatabase:DeleteById(id)
    if not success then
        return self.Templates:NotFound("Unable to find address with given id")
    end

    return self.Templates:Ok(success)
end

---@param id Core.UUID
---@return Net.Rest.Api.Response response
function Endpoints:GetAddressWithId(id)
    local address = self._AddressDatabase:GetWithId(id)
    if not address then
        return self.Templates:NotFound("Unable to find address with given id")
    end

    return self.Templates:Ok(address)
end

---@param addressStr string
---@return Net.Rest.Api.Response response
function Endpoints:GetAddressWithAddress(addressStr)
    local address = self._AddressDatabase:GetWithUrl(addressStr)
    if not address then
        return self.Templates:NotFound("Unable to find address with given address")
    end

    return self.Templates:Ok(address)
end

return Utils.Class.CreateClass(Endpoints, "DNS.Server.Endpoints",
    require("Net.Rest.Api.Server.EndpointBase") --[[@as Net.Rest.Api.Server.EndpointBase]])
