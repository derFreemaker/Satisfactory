---@class FactoryControl.Core.Entities.ControllerDto : object, Core.Json.ISerializable
---@field Id Core.UUID
---@field Name string
---@field IPAddress Net.Core.IPAddress
---@field Features Core.UUID[]
---@overload fun(id: Core.UUID, name: string, ipAddress: Net.Core.IPAddress, features: Core.UUID[]?) : FactoryControl.Core.Entities.ControllerDto
local ControllerDto = {}

---@alias FactoryControl.Core.Entities.ControllerDto.Constructor fun(id: Core.UUID, name: string, ipAddress: Net.Core.IPAddress, features: Core.UUID[]?) : FactoryControl.Core.Entities.ControllerDto

---@private
---@param id Core.UUID
---@param name string
---@param ipAddress Net.Core.IPAddress
---@param features Core.UUID[]?
function ControllerDto:__init(id, name, ipAddress, features)
    self.Id = id
    self.Name = name
    self.IPAddress = ipAddress
    self.Features = features or {}
end

---@return Core.UUID id, string name, Net.Core.IPAddress ipAddress, Core.UUID[] features
function ControllerDto:Serialize()
    return self.Id, self.Name, self.IPAddress, self.Features
end

return class("FactoryControl.Core.Entities.ControllerDto", ControllerDto,
    { IsAbstract = true, Inherit = require("Core.Json.ISerializable") })
