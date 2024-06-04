---@class Hosting.ServiceCollection : object
---@field private m_services table<string, object>
---@overload fun() : Hosting.ServiceCollection
local ServiceCollection = {}

---@private
function ServiceCollection:__init()
    self.m_services = {}
end

---@param service object
function ServiceCollection:AddService(service)
    self.m_services[nameof(service)] = service
end

---@param serviceTypeName string
---@return object?
function ServiceCollection:GetService(serviceTypeName)
    return self.m_services[serviceTypeName]
end

return class("Hosting.ServiceCollection", ServiceCollection)
