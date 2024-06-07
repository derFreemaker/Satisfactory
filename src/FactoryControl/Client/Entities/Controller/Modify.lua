local FeatureDto = require("FactoryControl.Core.Entities.Controller.Feature.Dto")

local ModfiyDto = require("FactoryControl.Core.Entities.Controller.ModifyDto")

---@class FactoryControl.Client.Entities.Controller.Modify : object
---@field Name string
---@field IPAddress Net.IPAddress
---@field Features table<Core.UUID, FactoryControl.Client.Entities.Controller.Feature>
---@overload fun(name: string, ipAddress: Net.IPAddress, features: table<Core.UUID, FactoryControl.Client.Entities.Controller.Feature>) : FactoryControl.Client.Entities.Controller.Modify
local Modify = {}

---@private
---@param name string
---@param ipAddress Net.IPAddress
---@param features table<Core.UUID, FactoryControl.Client.Entities.Controller.Feature>
function Modify:__init(name, ipAddress, features)
    self.Name = name
    self.IPAddress = ipAddress
    self.Features = features
end

function Modify:ToDto()
    ---@type table<Core.UUID, FactoryControl.Core.Entities.Controller.FeatureDto>
    local featureDtos = {}
    for key, feature in pairs(self.Features) do
        featureDtos[key] = feature:ToDto()
    end

    return ModfiyDto(self.Name, self.IPAddress, featureDtos)
end

return class("FactoryControl.Client.Entities.Controller.Modify", Modify)
