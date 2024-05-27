local DbTable = require("Database.DbTable")
local Path = require("Core.FileSystem.Path")
local UUID = require("Core.Common.UUID")

local ControllerDto = require("FactoryControl.Core.Entities.Controller.ControllerDto")

---@class FactoryControl.Server.DatabaseAccessLayer : object
---@field private m_controllers Database.DbTable
---@field private m_features Database.DbTable
---@field private m_logger Core.Logger
---@overload fun(logger: Core.Logger) : FactoryControl.Server.DatabaseAccessLayer
local DatabaseAccessLayer = {}

---@private
---@param logger Core.Logger
function DatabaseAccessLayer:__init(logger)
    self.m_controllers = DbTable("Controllers", Path("/Database/Controllers/"), logger:subLogger("ControllerTable"))
    self.m_features = DbTable("Features", Path("/Database/Features/"), logger:subLogger("FeaturesTable"))
    self.m_logger = logger

    self.m_controllers:Load()
    self.m_features:Load()
end

function DatabaseAccessLayer:Save()
    self.m_controllers:Save()
    self.m_features:Save()
end

--------------------------------------------------------------
-- Controller
--------------------------------------------------------------

---@param createController FactoryControl.Core.Entities.Controller.CreateDto
---@return FactoryControl.Core.Entities.ControllerDto? controller
function DatabaseAccessLayer:CreateController(createController)
    local controller = ControllerDto(UUID.Static__New(), createController.Name,
        createController.IPAddress, createController.Features)

    if self:GetControllerByName(createController.Name) then
        return nil
    end

    self.m_controllers:Set(controller.Id:ToString(), controller)
    self.m_controllers:Save()

    return controller
end

---@param controllerId Core.UUID
function DatabaseAccessLayer:DeleteController(controllerId)
    self.m_controllers:Delete(controllerId:ToString())
    self.m_controllers:Save()
end

---@param controllerId Core.UUID
---@return FactoryControl.Core.Entities.ControllerDto? controller
function DatabaseAccessLayer:GetControllerById(controllerId)
    return self.m_controllers:Get(controllerId:ToString())
end

---@param controllerName string
---@return FactoryControl.Core.Entities.ControllerDto? controller
function DatabaseAccessLayer:GetControllerByName(controllerName)
    for _, controller in pairs(self.m_controllers) do
        ---@cast controller FactoryControl.Core.Entities.ControllerDto

        if controller.Name == controllerName then
            return controller
        end
    end
end

--------------------------------------------------------------
-- Feature
--------------------------------------------------------------

---@param feature FactoryControl.Core.Entities.Controller.FeatureDto
---@return FactoryControl.Core.Entities.Controller.FeatureDto feature
function DatabaseAccessLayer:CreateFeature(feature)
    if self:GetFeatureById(feature.Id) then
        feature.Id = UUID.Static__New()
    end

    self.m_features:Set(feature.Id:ToString(), feature)
    self.m_features:Save()

    return feature
end

---@param featureId Core.UUID
function DatabaseAccessLayer:DeleteFeature(featureId)
    self.m_features:Delete(featureId:ToString())
    self.m_features:Save()
end

---@param featureId Core.UUID
---@return FactoryControl.Core.Entities.Controller.FeatureDto feature
function DatabaseAccessLayer:GetFeatureById(featureId)
    return self.m_features:Get(featureId:ToString())
end

---@param featureIds Core.UUID[]
---@return FactoryControl.Core.Entities.Controller.FeatureDto[] features
function DatabaseAccessLayer:GetFeatureByIds(featureIds)
    ---@type FactoryControl.Core.Entities.Controller.FeatureDto[]
    local features = {}

    for _, id in pairs(featureIds) do
        table.insert(features, self:GetFeatureById(id))
    end

    return features
end

return class("FactoryControl.Server.Database", DatabaseAccessLayer)
