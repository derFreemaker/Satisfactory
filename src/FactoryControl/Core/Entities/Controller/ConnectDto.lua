---@class FactoryControl.Core.Entities.Controller.ConnectDto : object, Core.Json.ISerializable
---@field Name string
---@field IPAddress Net.IPAddress
---@overload fun(name: string, ipAddress: Net.IPAddress) : FactoryControl.Core.Entities.Controller.ConnectDto
local ConnectDto = {}

---@private
---@param name string
---@param ipAddress Net.IPAddress
function ConnectDto:__init(name, ipAddress)
    self.Name = name
    self.IPAddress = ipAddress
end

---@return string name, Net.IPAddress ipAddress
function ConnectDto:Serialize()
    return self.Name, self.IPAddress
end

return class("FactoryControl.Core.Entities.Controller.ConnectDto", ConnectDto,
    { Inherit = require("Core.Json.ISerializable") })
