---@class Core.Reference<T> : Core.IReference<T>
---@field m_id FIN.UUID
---@overload fun(id: FIN.UUID) : Core.Reference
local Reference = {}

---@private
---@param id FIN.UUID
function Reference:__init(id)
    self.m_id = id
end

---@return boolean found
function Reference:Refresh()
    self.m_obj = component.proxy(self.m_id)
    return component ~= nil
end

return Utils.Class.CreateClass(Reference, "Core.Reference",
    require("Core.References.IReference"))
