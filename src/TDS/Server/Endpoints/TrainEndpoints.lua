local TrainUrlTemplates = require("TDS.Core.EndpointUrls")[1].Train

---@class TDS.Server.Endpoints.TrainEndpoints : Net.Rest.Api.Server.EndpointBase
---@field m_databaseAccessLayer TDS.Server.DatabaseAccessLayer
local TrainEndpoints = {}

---@private
---@param logger Core.Logger
---@param apiController Net.Rest.Api.Server.Controller
---@param databaseAccessLayer TDS.Server.DatabaseAccessLayer
---@param super Net.Rest.Api.Server.EndpointBase.Constructor
function TrainEndpoints:__init(super, logger, apiController, databaseAccessLayer)
    super(logger, apiController)

    self.m_databaseAccessLayer = databaseAccessLayer

    self:AddEndpoint("CREATE", TrainUrlTemplates.Create, self.Create)
end

---@param createTrain TDS.Entities.Train.Create
---@return Net.Rest.Api.Response
function TrainEndpoints:Create(createTrain)
    local train = self.m_databaseAccessLayer:CreateTrain(createTrain)
    return self.Templates:Ok(train)
end

return class("TDS.Server.Endpoints.TrainEndpoints", TrainEndpoints,
    { Inherit = require("Net.Rest.Api.Server.EndpointBase") })
