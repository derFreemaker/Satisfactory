---@class FactoryControl.Core.Entities.Controller.ModifyDto : object, Core.Json.ISerializable
---@field Name string
---@field IPAddress Net.IPAddress
---@field Features Core.UUID[]
---@overload fun(name: string, ipAddress: Net.IPAddress, features: Core.UUID[]) : FactoryControl.Core.Entities.Controller.ModifyDto
local ModifyDto = {}

---@private
---@param name string
---@param ipAddress Net.IPAddress
---@param features Core.UUID[]
function ModifyDto:__init(name, ipAddress, features)
    self.Name = name
    self.IPAddress = ipAddress
    self.Features = features
end

---@return string name, Net.IPAddress ipAddress, table<Core.UUID, FactoryControl.Core.Entities.Controller.FeatureDto> features
function ModifyDto:Serialize()
    return self.Name, self.IPAddress, self.Features
end

return class("FactoryControl.Core.Entities.Controller.ModifyDto", ModifyDto,
    { Inherit = require("Core.Json.ISerializable") })
