---@class FactoryControl.Core.EndpointUrlTemplates
local EndpointUrlTemplates = {}

---@class FactoryControl.Core.EndpointUrlConstructors
local EndpointUrlConstructors = {}

--------------------------------------------------------------
-- Controller
--------------------------------------------------------------

---@class FactoryControl.Core.EndpointUrlTemplates.Controller
local ControllerTemplates = {}

---@class FactoryControl.Core.EndpointUrlConstructors.Controller
local ControllerConstructors = {}

ControllerTemplates.Connect = "/Controller/Connect"
function ControllerConstructors.Connect()
    return "/Controller/Connect"
end

ControllerTemplates.Create = "/Controller/Create"
function ControllerConstructors.Create()
    return "/Controller/Create"
end

ControllerTemplates.Delete = "/Controller/{id:Core.UUID}/Delete"
---@param id Core.UUID
function ControllerConstructors.Delete(id)
    return "/Controller/" .. id:ToString() .. "/Delete"
end

ControllerTemplates.Modify = "/Controller/{id:Core.UUID}/Modify"
---@param id Core.UUID
function ControllerConstructors.Modify(id)
    return "/Controller/" .. id:ToString() .. "/Modify"
end

ControllerTemplates.GetById = "/Controller/{id:Core.UUID}"
---@param id Core.UUID
function ControllerConstructors.GetById(id)
    return "/Controller/" .. id:ToString()
end

ControllerTemplates.GetByName = "/Controller/GetWithName/{name:string}"
---@param name string
function ControllerConstructors.GetByName(name)
    return "/Controller/GetWithName/" .. name
end

EndpointUrlTemplates.Controller = ControllerTemplates
EndpointUrlConstructors.Controller = ControllerConstructors

--------------------------------------------------------------
-- Features
--------------------------------------------------------------

---@class FactoryControl.Core.EndpointUrlTemplates.Feature
local FeatureTemplates = {}

---@class FactoryControl.Core.EndpointUrlConstructors.Feature
local FeatureConstructors = {}

FeatureTemplates.Create = "/Feature/Create"
function FeatureConstructors.Create()
    return "/Feature/Create"
end

FeatureTemplates.Delete = "/Feature/{id:Core.UUID}/Delete"
---@param id Core.UUID
function FeatureConstructors.Delete(id)
    return "/Feature/" .. id:ToString() .. "/Delete"
end

FeatureTemplates.GetById = "/Feature/GetByIds"
function FeatureConstructors.GetByIds()
    return "/Feature/GetByIds"
end

EndpointUrlTemplates.Feature = FeatureTemplates
EndpointUrlConstructors.Feature = FeatureConstructors

return { EndpointUrlTemplates, EndpointUrlConstructors }
