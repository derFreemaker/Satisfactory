---@class Core.IReference<T> : object, { Get: fun() : T }
---@field protected m_obj Satisfactory.Components.Object?
local IReference = {}

---@generic TReference : FIN.Component
---@return TReference
function IReference:Get()
    if not self:IsValid() then
        if not self:Refresh() then
            error("could not be refreshed", 2)
        end
    end

    return self.m_obj
end

---@return boolean isValid
function IReference:IsValid()
    if not self.m_obj then
        return false
    end

    local success = pcall(function() local _ = self.m_obj.hash end)
    return success
end

---@return boolean found
function IReference:Refresh()
    error("cannot call abstract method IReference:Refresh")
end

function IReference:Check()
    if not self:IsValid() then
        if not self:Refresh() then
            error("could not be refreshed", 2)
        end
    end
end

return Utils.Class.CreateClass(IReference, "Core.IReference")
