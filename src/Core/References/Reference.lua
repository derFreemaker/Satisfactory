local Config = require("Core.Config")

---@generic T : Engine.Object
---@class Core.Ref<T> : interface, { Get: (fun() : T), IsValid: (fun() : boolean) }
---@field protected m_ref Engine.Object | nil
---@field m_expires number
local Ref = {}

Ref.m_expires = 0

---@return any
function Ref:Get()
    if self.m_expires < computer.millis() then
        self.m_ref = nil
        if not self:Fetch() then
            return nil
        end

        self.m_expires = computer.millis() + Config.REFERENCE_REFRESH_DELAY
    end

    return self.m_ref
end

---@return boolean found
function Ref:Fetch()
    return false
end
Ref.Fetch = Utils.Class.IsInterface

---@return boolean isValid
function Ref:IsValid()
    return self:Get() == nil
end

return interface("Core.Reference", Ref)
