---@class FactoryControl.Client.Entities.Controller.Feature.Button.Pressed : Core.Json.Serializable
---@field Id Core.UUID
---@overload fun(id: Core.UUID) : FactoryControl.Client.Entities.Controller.Feature.Button.Pressed
local Pressed = {}

---@private
---@param id Core.UUID
function Pressed:__init(id)
    self.Id = id
end

---@return Core.UUID id
function Pressed:Serialize()
    return self.Id
end

return Utils.Class.CreateClass(Pressed, "FactoryControl.Client.Entities.Controller.Feature.Button.Pressed",
    require("Core.Json.Serializable"))
