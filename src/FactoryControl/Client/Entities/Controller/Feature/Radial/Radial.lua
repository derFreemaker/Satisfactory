---@class FactoryControl.Client.Entities.Controller.Feature.Radial : FactoryControl.Client.Entities.Controller.Feature
---@field private _Max number
---@field private _Min number
---@field private _Setting number
---@overload fun(radialDto: FactoryControl.Core.Entities.Controller.Feature.RadialDto, controller: FactoryControl.Client.Entities.Controller) : FactoryControl.Client.Entities.Controller.Feature.Radial
local Radial = {}

---@private
---@param radialDto FactoryControl.Core.Entities.Controller.Feature.RadialDto
---@param controller FactoryControl.Client.Entities.Controller
---@param baseFunc fun(id: Core.UUID, name: string, type: FactoryControl.Core.Entities.Controller.Feature.Type, controller: FactoryControl.Client.Entities.Controller)
function Radial:__init(baseFunc, radialDto, controller)
    baseFunc(radialDto.Id, radialDto.Name, "Radial", controller)

    self._Max = radialDto.Max
    self._Min = radialDto.Min
    self._Setting = radialDto.Setting
end

-- //TODO: complete

return Utils.Class.CreateClass(Radial, "FactoryControl.Client.Entities.Controller.Feature.Radial",
    require("FactoryControl.Client.Entities.Controller.Feature.Feature") --[[@as FactoryControl.Client.Entities.Controller.Feature]])
