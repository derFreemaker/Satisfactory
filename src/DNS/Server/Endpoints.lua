local AddressDatabase = require("DNS.Server.AddressDatabase")
local AddressEntities = {
    Create = require("DNS.Core.Entities.Address.Create")
}

---@class DNS.Endpoints : Net.Rest.Api.Server.EndpointBase
---@field private _AddressDatabase DNS.Server.AddressDatabase
---@field private _Logger Core.Logger
---@overload fun(logger: Core.Logger) : DNS.Endpoints
local Endpoints = {}


---@private
---@param logger Core.Logger
function Endpoints:__init(logger)
    self._AddressDatabase = AddressDatabase(logger:subLogger("AddressDatabase"))
    self._Logger = logger
end

---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function Endpoints:CREATE__Address(request)
    ---@type DNS.Core.Entities.Address.Create
    local createAddress = AddressEntities.Create:Static__CreateFromData(request.Body)

    local success = self._AddressDatabase:Create(createAddress)
    return self.Templates:Ok(success)
end

---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function Endpoints:DELETE__Address(request)
    local success = self._AddressDatabase:Delete(request.Body)
    if not success then
        return self.Templates:NotFound("Unable to find address with given id")
    end
    return self.Templates:Ok(success)
end

---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function Endpoints:GET__AddressWithAddress(request)
    local address = self._AddressDatabase:GetWithAddress(request.Body)
    if not address then
        return self.Templates:NotFound("Unable to find address with given address")
    end
    return self.Templates:Ok(address:ExtractData())
end

---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function Endpoints:GET__AddressWithId(request)
    local address = self._AddressDatabase:GetWithId(request.Body)
    if not address then
        return self.Templates:NotFound("Unable to find address with given id")
    end
    return self.Templates:Ok(address:ExtractData())
end

return Utils.Class.CreateClass(Endpoints, "DNS.Server.Endpoints", require("Net.Rest.Api.Server.EndpointBase"))
