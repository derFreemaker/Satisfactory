local ButtonDto = require("FactoryControl.Core.Entities.Controller.Feature.ButtonDto")

local Pressed = require("FactoryControl.Client.Entities.Controller.Feature.Button.Update")

---@class FactoryControl.Client.Entities.Controller.Feature.Button : FactoryControl.Client.Entities.Controller.Feature
---@overload fun(buttonDto: FactoryControl.Core.Entities.Controller.Feature.ButtonDto, client: FactoryControl.Client) : FactoryControl.Client.Entities.Controller.Feature.Button
local Button = {}

---@private
---@param buttonDto FactoryControl.Core.Entities.Controller.Feature.ButtonDto
---@param client FactoryControl.Client
---@param baseFunc FactoryControl.Client.Entities.Controller.Feature.Constructor
function Button:__init(baseFunc, buttonDto, client)
    baseFunc(buttonDto, client)
end

---@return FactoryControl.Core.Entities.Controller.Feature.ButtonDto
function Button:ToDto()
    return ButtonDto(self.Id, self.Name, self.ControllerId)
end

function Button:Press()
    local pressed = Pressed(self.Id)
    self.m_client:UpdateFeature(pressed)
end

return Utils.Class.CreateClass(Button, "FactoryControl.Client.Entities.Controller.Feature.Button",
    require("FactoryControl.Client.Entities.Controller.Feature.Feature") --[[@as FactoryControl.Client.Entities.Controller.Feature]])
