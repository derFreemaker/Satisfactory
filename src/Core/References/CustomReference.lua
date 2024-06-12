---@class Core.CustomReference<T> : object, Core.Reference<T>
---@field m_fetchFunc fun() : Engine.Object | nil
---@overload fun(fetchFunc: (fun() : Engine.Object | nil), obj: Engine.Object | nil) : Core.CustomReference
local CustomReference = {}

---@private
---@param fetchFunc fun() : Engine.Object | nil
---@param obj Engine.Object | nil
function CustomReference:__init(fetchFunc, obj)
    self.m_fetchFunc = fetchFunc
    self.m_obj = obj
end

---@return boolean success
function CustomReference:Fetch()
    self.m_obj = self.m_fetchFunc()
    return self.m_obj ~= nil
end

return class("Core.CustomReference", CustomReference,
    { Inherit = require("Core.References.Reference") })
