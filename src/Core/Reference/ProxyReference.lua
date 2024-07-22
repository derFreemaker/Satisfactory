local Cache = require("Core.Common.Cache")

---@type Core.Cache<FIN.UUID, Core.ProxyRef>
local ProxyRefCache = Cache(nil, true)

---@class Core.ProxyRef<T> : object, Core.Ref<T>
---@field m_uuid FIN.UUID
---@overload fun(id: FIN.UUID) : Core.ProxyRef
local ProxyRef = {}

---@private
---@param uuid FIN.UUID
---@return Core.ProxyRef | nil
function ProxyRef:__preinit(uuid)
    return ProxyRefCache:Get(uuid)
end

---@private
---@param uuid FIN.UUID
function ProxyRef:__init(uuid)
    self.m_uuid = uuid

    ProxyRefCache:Add(uuid, self)
end

function ProxyRef:Fetch()
    local ref = component.proxy(self.m_uuid)
    self.m_ref = ref
    return ref ~= nil
end

return class("Core.ProxyReference", ProxyRef,
    { Inherit = require("Core.Reference.Reference") })
