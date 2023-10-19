local Pressed = require("FactoryControl.Client.Entities.Controller.Feature.Button.Pressed")

---@class FactoryControl.Client.Entities.Controller.Feature.Button : FactoryControl.Client.Entities.Controller.Feature
---@overload fun(buttonDto: FactoryControl.Core.Entities.Controller.Feature.ButtonDto, controller: FactoryControl.Client.Entities.Controller) : FactoryControl.Client.Entities.Controller.Feature.Button
local Button = {}

---@private
---@param buttonDto FactoryControl.Core.Entities.Controller.Feature.ButtonDto
---@param controller FactoryControl.Client.Entities.Controller
---@param baseFunc fun(id: Core.UUID, name: string, type: FactoryControl.Core.Entities.Controller.Feature.Type, controller: FactoryControl.Client.Entities.Controller)
function Button:__init(baseFunc, buttonDto, controller)
    baseFunc(buttonDto.Id, buttonDto.Name, "Button", controller)
end

function Button:Press()
    local pressed = Pressed(self.Id)

    self._Client:ButtonPressed(self.Owner.IPAddress, pressed)
end

return Utils.Class.CreateClass(Button, "FactoryControl.Client.Entities.Controller.Feature.Button",
    require("FactoryControl.Client.Entities.Controller.Feature.Feature") --[[@as FactoryControl.Client.Entities.Controller.Feature]])
