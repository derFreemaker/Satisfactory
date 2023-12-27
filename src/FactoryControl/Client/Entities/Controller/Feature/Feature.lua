local Task = require("Core.Common.Task")
local Watchable = require("Core.Common.Watchable")

---@class FactoryControl.Client.Entities.Controller.Feature : FactoryControl.Client.Entities.Entity
---@field Name string
---@field ControllerId Core.UUID
---@field Type FactoryControl.Core.Entities.Controller.Feature.Type
---@field OnChanged Core.Watchable
---@overload fun(id: Core.UUID, name: string, controllerId: Core.UUID, type: FactoryControl.Core.Entities.Controller.Feature.Type, client: FactoryControl.Client) : FactoryControl.Client.Entities.Controller.Feature
local Feature = {}

---@alias FactoryControl.Client.Entities.Controller.Feature.Constructor fun(dto: FactoryControl.Core.Entities.Controller.FeatureDto, client: FactoryControl.Client)

---@private
---@param dto FactoryControl.Core.Entities.Controller.FeatureDto
---@param client FactoryControl.Client
---@param super FactoryControl.Client.Entities.Entity.Constructor
function Feature:__init(super, dto, client)
    super(dto.Id, client)

    self.Name = dto.Name
    self.ControllerId = dto.ControllerId
    self.Type = dto.Type

    ---@param Watchable Core.Watchable
    local function onSetup(Watchable)
        self.m_client:WatchFeature(self)
    end

    ---@param Watchable Core.Watchable
    local function onClose(Watchable)
        self.m_client:UnwatchFeature(self.Id)
    end

    self.OnChanged = Watchable(onSetup, onClose)
end

---@param update FactoryControl.Core.Entities.Controller.Feature.Update
function Feature:OnUpdate(update)
    error("OnUpdate not implemented")
end

---@return FactoryControl.Core.Entities.Controller.FeatureDto
function Feature:ToDto()
    error("ToDto not implemented")
end

return Utils.Class.Create(Feature, "FactoryControl.Client.Entities.Controller.Feature",
    require("FactoryControl.Client.Entities.Entity"))
