---@class Core.IReference<T> : object, { Get: fun() : T }
---@field protected m_obj Satisfactory.Components.Object?
local IReference = {}

---@private
function IReference:__gc()
    log("__gc called on reference")
    self.m_obj = nil
end

---@return Satisfactory.Components.Object
function IReference:Get()
    self:Check()

    return self.m_obj
end

---@return boolean isValid
function IReference:IsValid()
    if not self.m_obj then
        return false
    end

    log("trying to see if reference is valid")
    local success = Utils.Function.InvokeProtected(function(obj) local _ = obj.hash end, self.m_obj)
    log("reference is valid: " .. tostring(success))

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
        elseif not self:IsValid() then
            error("not valid after refresh", 2)
        end
    end
end

return Utils.Class.CreateClass(IReference, "Core.IReference")
