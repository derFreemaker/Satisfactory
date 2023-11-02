local UUID = require("Core.UUID")

local FeatureUrlTemplates = require("FactoryControl.Core.EndpointUrls")[1].Feature

---@class FactoryControl.Server.Endpoints.Feature : Net.Rest.Api.Server.EndpointBase
---@field m_databaseAccessLayer FactoryControl.Server.Database
local FeatureEndpoints = {}

---@private
---@param logger Core.Logger
---@param apiController Net.Rest.Api.Server.Controller
---@param databaseAccessLayer FactoryControl.Server.Database
---@param baseFunc fun(endpointLogger: Core.Logger, apiController: Net.Rest.Api.Server.Controller)
function FeatureEndpoints:__init(baseFunc, logger, apiController, databaseAccessLayer)
    baseFunc(logger, apiController)

    self.m_databaseAccessLayer = databaseAccessLayer

    self:AddEndpoint("CREATE", FeatureUrlTemplates.Create, self.Create)
    self:AddEndpoint("DELETE", FeatureUrlTemplates.Delete, self.Delete)
    self:AddEndpoint("GET", FeatureUrlTemplates.GetById, self.GetByIds)
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

return Utils.Class.CreateClass(FeatureEndpoints, "FactoryControl.Server.Endpoints.Feature",
    require("Net.Rest.Api.Server.EndpointBase") --[[@as Net.Rest.Api.Server.EndpointBase]])
