local Usage = require("Core.Usage.init")
local Config = require("FactoryControl.Core.Config")

local Task = require("Core.Common.Task")

---@class FactoryControl.Server.Services.FeatureService : object
---@field OnFeatureInvoked Core.Task
---@field private m_watchedFeatures table<string, Net.Core.IPAddress[]>
---@field private m_callbackService Services.Callback.Server.CallbackService
---@field private m_databaseAccessLayer FactoryControl.Server.DatabaseAccessLayer
---@field private m_networkClient Net.Core.NetworkClient
---@overload fun(callbackService: Services.Callback.Server.CallbackService, databaseAccessLayer: FactoryControl.Server.DatabaseAccessLayer, networkClient: Net.Core.NetworkClient) : FactoryControl.Server.Services.FeatureService
local FeatureService = {}

---@private
---@param callbackService Services.Callback.Server.CallbackService
---@param databaseAccessLayer FactoryControl.Server.DatabaseAccessLayer
---@param networkClient Net.Core.NetworkClient
function FeatureService:__init(callbackService, databaseAccessLayer, networkClient)
    self.m_watchedFeatures = {}
    self.m_callbackService = callbackService
    self.m_databaseAccessLayer = databaseAccessLayer
    self.m_networkClient = networkClient

    self.OnFeatureInvoked = Task(self.onFeatureInvoked, self)
end

---@param featureId Core.UUID
---@param ipAddress Net.Core.IPAddress
function FeatureService:Watch(featureId, ipAddress)
    local ipAddresses = self.m_watchedFeatures[featureId:ToString()]
    if not ipAddresses then
        ipAddresses = {}
        self.m_watchedFeatures[featureId:ToString()] = ipAddresses
    end

    table.insert(ipAddresses, ipAddress)
end

---@param featureId Core.UUID
---@param ipAddress Net.Core.IPAddress
function FeatureService:Unwatch(featureId, ipAddress)
    local ipAddresses = self.m_watchedFeatures[featureId:ToString()]
    if not ipAddresses then
        return
    end

    for i, ip in ipairs(ipAddresses) do
        if ip == ipAddress then
            table.remove(ipAddresses, i)
            return
        end
    end
end

---@private
---@param context Net.Core.NetworkContext
function FeatureService:onFeatureInvoked(context)
    local featureUpdate = context:GetFeatureUpdate()

    local feature = self.m_databaseAccessLayer:GetFeatureById(featureUpdate.FeatureId)
    if not feature then
        self.m_watchedFeatures[featureUpdate.FeatureId:ToString()] = nil
    end

    feature:OnUpdate(featureUpdate)

    self:SendToController(feature, featureUpdate)
    self:SendToWachters(featureUpdate)
end

---@param feature FactoryControl.Core.Entities.Controller.FeatureDto
---@param featureUpdate FactoryControl.Core.Entities.Controller.Feature.Update
function FeatureService:SendToController(feature, featureUpdate)
    local controller = self.m_databaseAccessLayer:GetControllerById(feature.ControllerId)
    if not controller then
        return
    end

    self.m_callbackService:Send(
        feature.Id,
        Usage.Events.FactoryControl_Feature_Update,
        Config.CallbackServiceNameForFeatures,
        controller.IPAddress,
        { featureUpdate }
    )
end

---@param featureUpdate FactoryControl.Core.Entities.Controller.Feature.Update
function FeatureService:SendToWachters(featureUpdate)
    local ipAddresses = self.m_watchedFeatures[featureUpdate.FeatureId:ToString()]
    if not ipAddresses then
        return
    end

    for _, ipAddress in ipairs(ipAddresses) do
        self.m_callbackService:Send(
            featureUpdate.FeatureId,
            Usage.Events.FactoryControl_Feature_Update,
            Config.CallbackServiceNameForFeatures,
            ipAddress,
            { featureUpdate }
        )
    end
end

return Utils.Class.CreateClass(FeatureService, "FactoryControl.Server.Services.FeatureService")
