---@class DNS.Core.Entities.Address.Create : Core.Json.Serializable
---@field Url string
---@field IPAddress Net.Core.IPAddress
---@overload fun(url: string, ipAddress: Net.Core.IPAddress) : DNS.Core.Entities.Address.Create
local Create = {}

---@private
---@param url string
---@param ipAddress Net.Core.IPAddress
function Create:__init(url, ipAddress)
    self.Url = url
    self.IPAddress = ipAddress
end

---@return string url, Net.Core.IPAddress ipAddress
function Create:Serialize()
    return self.Url, self.IPAddress
end

return Utils.Class.CreateClass(Create, "DNS.Entities.Address.Create",
    require("Core.Json.Serializable"))
