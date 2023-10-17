---@class FactoryControl.Client.Entities.Controller.Feature.Button : FactoryControl.Client.Entities.Controller.Feature
---@overload fun(buttonDto: FactoryControl.Core.Entities.Controller.Feature.ButtonDto) : FactoryControl.Client.Entities.Controller.Feature.Button
local Button = {}

---@private
---@param buttonDto FactoryControl.Core.Entities.Controller.Feature.ButtonDto
---@param baseFunc fun(id: Core.UUID, name: string, type: FactoryControl.Core.Entities.Controller.Feature.Type)
function Button:__init(baseFunc, buttonDto)
    baseFunc(buttonDto.Id, buttonDto.Name, "Button")
end

-- //TODO: complete

return Utils.Class.CreateClass(Button, "FactoryControl.Client.Entities.Controller.Feature.Button",
    require("FactoryControl.Client.Entities.Controller.Feature.Feature") --[[@as FactoryControl.Client.Entities.Controller.Feature]])
