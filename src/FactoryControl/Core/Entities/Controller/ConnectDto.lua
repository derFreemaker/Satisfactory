---@class FactoryControl.Core.Entities.Controller.ConnectDto : Core.Json.Serializable
---@field Name string
---@field IPAddress Net.Core.IPAddress
---@overload fun(name: string, ipAddress: Net.Core.IPAddress) : FactoryControl.Core.Entities.Controller.ConnectDto
local ConnectDto = {}

---@private
---@param name string
---@param ipAddress Net.Core.IPAddress
function ConnectDto:__init(name, ipAddress)
    self.Name = name
    self.IPAddress = ipAddress
end

---@return string name, Net.Core.IPAddress ipAddress
function ConnectDto:Serialize()
    return self.Name, self.IPAddress
end

return Utils.Class.Create(ConnectDto, "FactoryControl.Core.Entities.Controller.ConnectDto",
    require("Core.Json.Serializable"))
