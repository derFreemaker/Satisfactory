local Usage = require("Core.Usage.init")
local Config = require("FactoryControl.Core.Config")

local Task = require("Core.Common.Task")
local NetworkClient = require("Net.Core.NetworkClient")

local DataClient = require("FactoryControl.Client.DataClient")

local Controller = require("FactoryControl.Client.Entities.Controller.Controller")
local CreateController = require("FactoryControl.Core.Entities.Controller.CreateDto")
local ConnectController = require("FactoryControl.Core.Entities.Controller.ConnectDto")

local FeatureFactory = require("FactoryControl.Client.Entities.Controller.Feature.Factory")

local Callback = require("Services.Callback.Client.Callback")
local CallbackService = require("Services.Callback.Client.CallbackService")

---@class FactoryControl.Client : object
---@field CurrentController FactoryControl.Client.Entities.Controller
---@field NetClient Net.Core.NetworkClient
---@field private m_callbackService Services.Callback.Client.CallbackService
---@field private m_client FactoryControl.Client.DataClient
---@field private m_logger Core.Logger
---@overload fun(logger: Core.Logger, client: FactoryControl.Client.DataClient?, networkClient: Net.Core.NetworkClient?) : FactoryControl.Client
local Client = {}

---@private
---@param logger Core.Logger
---@param client FactoryControl.Client.DataClient?
---@param networkClient Net.Core.NetworkClient?
function Client:__init(logger, client, networkClient)
    self.NetClient = networkClient or NetworkClient(logger:subLogger("NetClient"))

    self.m_callbackService = CallbackService(
        Config.CallbackServiceNameForFeatures,
        logger:subLogger("CallbackService"),
        self.NetClient
    )
    self.m_client = client or DataClient(logger:subLogger("DataClient"), self.NetClient)
    self.m_logger = logger
end

------------------------------------------------------------------------------
-- Controller
------------------------------------------------------------------------------

---@param name string
---@param features FactoryControl.Client.Entities.Controller.Feature[]?
---@return FactoryControl.Client.Entities.Controller
function Client:Connect(name, features)
    local controllerDto = self.m_client:Connect(ConnectController(name, self.NetClient:GetIPAddress()))

    local created = false
    if not controllerDto then
        controllerDto = self.m_client:CreateController(CreateController(name, self.NetClient:GetIPAddress(), features))

        if not controllerDto then
            error("Unable to connect to server")
        end

        created = true
    end

    local controller = Controller(controllerDto, self)
    self.CurrentController = controller

    if not created then
        controller:Modify(function(modify)
            if not features then
                return
            end

            for _, feature in pairs(features) do
                modify.Features[feature.Name] = feature
            end
        end)
    end

    return controller
end

---@param createController FactoryControl.Core.Entities.Controller.CreateDto
---@return FactoryControl.Client.Entities.Controller? controller
function Client:CreateController(createController)
    local controllerDto = self.m_client:CreateController(createController)
    if not controllerDto then
        return
    end

    return Controller(controllerDto, self)
end

---@param id Core.UUID
---@return boolean success
function Client:DeleteControllerById(id)
    return self.m_client:DeleteControllerById(id)
end

---@param id Core.UUID
---@param modifyController FactoryControl.Core.Entities.Controller.ModifyDto
---@return boolean success, FactoryControl.Client.Entities.Controller?
function Client:ModfiyControllerById(id, modifyController)
    local controllerDto = self.m_client:ModifyControllerById(id, modifyController)

    if not controllerDto then
        return false
    end

    return true, Controller(controllerDto, self)
end

---@param id Core.UUID
---@return FactoryControl.Client.Entities.Controller? controller
function Client:GetControllerById(id)
    local controllerDto = self.m_client:GetControllerById(id)
    if not controllerDto then
        return
    end

    return Controller(controllerDto, self)
end

---@param name string
---@return FactoryControl.Client.Entities.Controller?
function Client:GetControllerByName(name)
    local controllerDto = self.m_client:GetControllerByName(name)
    if not controllerDto then
        return
    end

    return Controller(controllerDto, self)
end

------------------------------------------------------------------------------
-- Feature
------------------------------------------------------------------------------

---@param feature FactoryControl.Client.Entities.Controller.Feature
function Client:WatchFeature(feature)
    local callback = Callback(
        feature.Id,
        Usage.Events.FactoryControl_Feature_Update,
        Task(self.OnFeatureUpdate, self, feature)
    )
    self.m_callbackService:AddCallback(callback)

    for _, value in pairs(self.CurrentController:GetFeatureIds()) do
        if value:Equals(value) then
            return
        end
    end

    self.m_client:WatchFeature(feature.Id)
end

---@param featureId Core.UUID
function Client:UnwatchFeature(featureId)
    self.m_callbackService:RemoveCallback(featureId, Usage.Events.FactoryControl_Feature_Update)

    for _, value in pairs(self.CurrentController:GetFeatureIds()) do
        if value:Equals(featureId) then
            return
        end
    end

    self.m_client:UnwatchFeature(featureId)
end

---@private
---@param featureUpdate FactoryControl.Core.Entities.Controller.Feature.Update
function Client:OnFeatureUpdate(feature, featureUpdate)
    local logger = self.m_logger:subLogger("Feature[" .. feature.Id:ToString() .. "]")
    feature:OnUpdate(featureUpdate)
    feature.OnChanged:Trigger(logger, featureUpdate)
end

---@param feature FactoryControl.Client.Entities.Controller.Feature
---@return FactoryControl.Client.Entities.Controller.Feature?
function Client:CreateFeature(feature)
    local featureDto = self.m_client:CreateFeature(feature:ToDto())
    if not featureDto then
        return
    end

    return FeatureFactory.Create(featureDto, self)
end

---@param featureId Core.UUID
---@return boolean
function Client:DeleteFeatureById(featureId)
    return self.m_client:DeleteFeatureById(featureId)
end

---@param featureIds Core.UUID[]
---@return FactoryControl.Client.Entities.Controller.Feature?
function Client:GetFeatureByIds(featureIds)
    local featureDtos = self.m_client:GetFeatureByIds(featureIds)

    ---@type FactoryControl.Client.Entities.Controller.Feature[]
    local features = {}

    for _, featureDto in pairs(featureDtos) do
        local feature = FeatureFactory.Create(featureDto, self)
        table.insert(features, feature)
    end

    return features
end

---@param featureUpdate FactoryControl.Core.Entities.Controller.Feature.Update
function Client:UpdateFeature(featureUpdate)
    self.m_client:UpdateFeature(featureUpdate)
end

return Utils.Class.CreateClass(Client, "FactoryControl.Client")
