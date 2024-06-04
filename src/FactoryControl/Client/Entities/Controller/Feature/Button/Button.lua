local ButtonDto = require("FactoryControl.Core.Entities.Controller.Feature.Button.ButtonDto")

local Update = require("FactoryControl.Core.Entities.Controller.Feature.Button.Update")

---@class FactoryControl.Client.Entities.Controller.Feature.Button : FactoryControl.Client.Entities.Controller.Feature
---@overload fun(buttonDto: FactoryControl.Core.Entities.Controller.Feature.ButtonDto, client: FactoryControl.Client) : FactoryControl.Client.Entities.Controller.Feature.Button
local Button = {}

---@private
---@param buttonDto FactoryControl.Core.Entities.Controller.Feature.ButtonDto
---@param client FactoryControl.Client
---@param super FactoryControl.Client.Entities.Controller.Feature.Constructor
function Button:__init(super, buttonDto, client)
    super(buttonDto, client)
end

---@private
function Button:OnUpdate()
end

---@return FactoryControl.Core.Entities.Controller.Feature.ButtonDto
function Button:ToDto()
    return ButtonDto(self.Id, self.Name, self.ControllerId)
end

function Button:Press()
    local update = Update(self.Id)
    self.m_client:UpdateFeature(update)
end

return class("FactoryControl.Client.Entities.Controller.Feature.Button", Button,
    { Inherit = require("FactoryControl.Client.Entities.Controller.Feature.Feature") })
