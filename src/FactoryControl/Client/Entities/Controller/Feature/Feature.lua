local Event = require("Core.Event.Event")

---@class FactoryControl.Client.Entities.Controller.Feature : FactoryControl.Client.Entities.Entity
---@field Name string
---@field ControllerId Core.UUID
---@field Type FactoryControl.Core.Entities.Controller.Feature.Type
---@field OnChanged Core.Event
---@overload fun(id: Core.UUID, name: string, controllerId: Core.UUID, type: FactoryControl.Core.Entities.Controller.Feature.Type, client: FactoryControl.Client) : FactoryControl.Client.Entities.Controller.Feature
local Feature = {}

---@alias FactoryControl.Client.Entities.Controller.Feature.Constructor fun(dto: FactoryControl.Core.Entities.Controller.FeatureDto, client: FactoryControl.Client)

---@private
---@param dto FactoryControl.Core.Entities.Controller.FeatureDto
---@param client FactoryControl.Client
---@param baseFunc FactoryControl.Client.Entities.Entity.Constructor
function Feature:__init(baseFunc, dto, client)
    baseFunc(dto.Id, client)

    self.Name = dto.Name
    self.ControllerId = dto.ControllerId
    self.Type = dto.Type

    self.OnChanged = Event()
end

---@return FactoryControl.Core.Entities.Controller.FeatureDto
function Feature:ToDto()
    error("ToDto not implemented")
end

return Utils.Class.CreateClass(Feature, "FactoryControl.Client.Entities.Controller.Feature",
    require("FactoryControl.Client.Entities.Entity") --[[@as FactoryControl.Client.Entities.Entity]])
