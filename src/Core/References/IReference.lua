local Config = require("Core.Config")

---@generic TReference : Satisfactory.Components.Object
---@class Core.IReference<TReference> : object, { Get: fun() : TReference }
---@field protected m_obj Satisfactory.Components.Object?
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
    error("cannot call abstract method IReference:Fetch")
end

---@return boolean isValid
function IReference:Check()
    return self:Get() == nil
end

return Utils.Class.CreateClass(IReference, "Core.IReference")
