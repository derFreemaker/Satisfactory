local Usage = require("Core.Usage.Usage")
local Task = require("Core.Task")

local Modify = require("FactoryControl.Client.Entities.Controller.Modify")

---@class FactoryControl.Client.Entities.Controller : FactoryControl.Client.Entities.Entity
---@field Name string
---@field IPAddress Net.Core.IPAddress
---@field private m_featuresIds Core.UUID[]
---@field private m_features table<string, FactoryControl.Client.Entities.Controller.Feature>
---@overload fun(controllerDto: FactoryControl.Core.Entities.ControllerDto, client: FactoryControl.Client) : FactoryControl.Client.Entities.Controller
local Controller = {}

---@private
---@param controllerDto FactoryControl.Core.Entities.ControllerDto
---@param client FactoryControl.Client
---@param baseFunc FactoryControl.Client.Entities.Entity.Constructor
function Controller:__init(baseFunc, controllerDto, client)
    baseFunc(controllerDto.Id, client)

    self.Name = controllerDto.Name
    self.IPAddress = controllerDto.IPAddress
    self.m_featuresIds = controllerDto.Features
end

---@param func fun(modify: FactoryControl.Client.Entities.Controller.Modify)
function Controller:Modify(func)
    local modify = Modify(self.Name, self.IPAddress, self.m_featuresIds)

    func(modify)

    self.m_client:ModfiyControllerById(self.Id, modify:ToDto())
end

---@return FactoryControl.Client.Entities.Controller.Feature[]
function Controller:GetFeatures()
    if self.m_features then
        return self.m_features
    end

    local features = {}
    for _, feature in pairs(self.m_client:GetFeatureByIds(self.m_featuresIds) or {}) do
        features[feature.Id:ToString()] = feature
    end

    self.m_features = features
    return self.m_features
end

return Utils.Class.CreateClass(Controller, "FactoryControl.Client.Entities.Controller",
    require("FactoryControl.Client.Entities.Entity") --[[@as FactoryControl.Client.Entities.Entity]])

-- //TODO: implement some kind of status like online and offline
