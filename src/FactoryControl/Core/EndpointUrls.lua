---@class FactoryControl.Core.EndpointUrlTemplates
local EndpointUrlTemplates = {}

---@class FactoryControl.Core.EndpointUrlConstructors
local EndpointUrlConstructors = {}

EndpointUrlTemplates.Connect = "/Controller/Connect"
function EndpointUrlConstructors.Connect()
    return "/Controller/Connect"
end

EndpointUrlTemplates.Create = "/Controller/Create"
function EndpointUrlConstructors.Create()
    return "/Controller/Create"
end

EndpointUrlTemplates.Delete = "/Controller/{id:Core.UUID}/Delete"
---@param id Core.UUID
function EndpointUrlConstructors.Delete(id)
    return "/Controller/" .. id:ToString() .. "/Delete"
end

EndpointUrlTemplates.Modify = "/Controller/{id:Core.UUID}/Modify"
---@param id Core.UUID
function EndpointUrlConstructors.Modify(id)
    return "/Controller/" .. id:ToString() .. "/Modify"
end

EndpointUrlTemplates.GetById = "/Controller/{id:Core.UUID}"
---@param id Core.UUID
function EndpointUrlConstructors.GetById(id)
    return "/Controller/" .. id:ToString()
end

EndpointUrlTemplates.GetByName = "/Controller/GetWithName/{name:string}"
---@param name string
function EndpointUrlConstructors.GetByName(name)
    return "/Controller/GetWithName/" .. name
end

return { EndpointUrlTemplates, EndpointUrlConstructors }
