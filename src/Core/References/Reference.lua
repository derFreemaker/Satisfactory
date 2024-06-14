local Config = require("Core.Config")

---@generic T : Engine.Object
---@class Core.Reference<T> : { Get: (fun() : T), IsValid: (fun() : boolean) }
---@field protected m_obj Engine.Object | nil
---@field m_expires number
local IReference = {}

IReference.m_expires = 0

---@return any
function IReference:Get()
    if self.m_expires < computer.millis() then
        if not self:Fetch() then
            return nil
        end

        self.m_expires = computer.millis() + Config.REFERENCE_REFRESH_DELAY
    end

    return self.m_obj
end

---@return boolean found
function IReference:Fetch()
    return false
end
IReference.Fetch = Utils.Class.IsInterface

---@return boolean isValid
function IReference:IsValid()
    return self:Get() == nil
end

return interface("Core.Reference", IReference)
