---@class FactoryControl.Core.Entities.Controller.ModifyDto : Core.Json.Serializable
---@field Name string
---@field IPAddress Net.Core.IPAddress
---@field Features Core.UUID[]
---@overload fun(name: string, ipAddress: Net.Core.IPAddress, features: Core.UUID[]) : FactoryControl.Core.Entities.Controller.ModifyDto
local ModifyDto = {}

---@private
---@param name string
---@param ipAddress Net.Core.IPAddress
---@param features Core.UUID[]
function ModifyDto:__init(name, ipAddress, features)
    self.Name = name
    self.IPAddress = ipAddress
    self.Features = features
end

---@return string name, Net.Core.IPAddress ipAddress, table<Core.UUID, FactoryControl.Core.Entities.Controller.FeatureDto> features
function ModifyDto:Serialize()
    return self.Name, self.IPAddress, self.Features
end

return Utils.Class.CreateClass(ModifyDto, "FactoryControl.Core.Entities.Controller.ModifyDto",
    require("Core.Json.Serializable"))
