---@class Core.ProxyReference<T> : Core.IReference<T>
---@field m_id FIN.UUID
---@overload fun(id: FIN.UUID) : Core.ProxyReference
local ProxyReference = {}

---@private
---@param id FIN.UUID
function ProxyReference:__init(id)
    self.m_id = id
end

function ProxyReference:Fetch()
    local obj = component.proxy(self.m_id)
    self.m_obj = obj
    return obj ~= nil
end

return Utils.Class.CreateClass(ProxyReference, "Core.ProxyReference",
    require("Core.References.IReference"))
