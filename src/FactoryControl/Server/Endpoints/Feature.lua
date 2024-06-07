local FeatureUrlTemplates = require("FactoryControl.Core.EndpointUrls")[1].Feature

---@class FactoryControl.Server.Endpoints.Feature : Net.Rest.Api.Server.EndpointBase
---@field m_databaseAccessLayer FactoryControl.Server.DatabaseAccessLayer
---@field m_featureService FactoryControl.Server.Services.FeatureService
local FeatureEndpoints = {}

---@private
---@param logger Core.Logger
---@param apiController Net.Rest.Api.Server.Controller
---@param databaseAccessLayer FactoryControl.Server.DatabaseAccessLayer
---@param featureService FactoryControl.Server.Services.FeatureService
---@param super Net.Rest.Api.Server.EndpointBase.Constructor
function FeatureEndpoints:__init(super, logger, apiController, databaseAccessLayer, featureService)
    super(logger, apiController)

    self.m_databaseAccessLayer = databaseAccessLayer
    self.m_featureService = featureService

    self:AddEndpoint("POST", FeatureUrlTemplates.Watch, self.Watch)
    self:AddEndpoint("POST", FeatureUrlTemplates.Unwatch, self.Unwatch)

    self:AddEndpoint("CREATE", FeatureUrlTemplates.Create, self.Create)
    self:AddEndpoint("DELETE", FeatureUrlTemplates.Delete, self.Delete)
    self:AddEndpoint("GET", FeatureUrlTemplates.GetById, self.GetByIds)
end

---@param featureId Core.UUID
---@param ipAddress Net.IPAddress
---@return Net.Rest.Api.Response response
function FeatureEndpoints:Watch(featureId, ipAddress)
    self.m_featureService:Watch(featureId, ipAddress)
    return self.Templates:Ok(true)
end

---@param featureId Core.UUID
---@param ipAddress Net.IPAddress
---@return Net.Rest.Api.Response response
function FeatureEndpoints:Unwatch(featureId, ipAddress)
    self.m_featureService:Unwatch(featureId, ipAddress)
    return self.Templates:Ok(true)
end

---@param feature FactoryControl.Core.Entities.Controller.FeatureDto
---@return Net.Rest.Api.Response response
function FeatureEndpoints:Create(feature)
    feature = self.m_databaseAccessLayer:CreateFeature(feature)
    return self.Templates:Ok(feature)
end

---@param id Core.UUID
---@return Net.Rest.Api.Response response
function FeatureEndpoints:Delete(id)
    self.m_databaseAccessLayer:DeleteFeature(id)
    return self.Templates:Ok(true)
end

---@param featureIds Core.UUID[]
---@return Net.Rest.Api.Response response
function FeatureEndpoints:GetByIds(featureIds)
    local features = self.m_databaseAccessLayer:GetFeatureByIds(featureIds)

    return self.Templates:Ok(features)
end

return class("FactoryControl.Server.Endpoints.Feature", FeatureEndpoints,
    { Inherit =  require("Net.Rest.Api.Server.EndpointBase") })
