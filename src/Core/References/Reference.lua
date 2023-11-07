---@class Core.Reference : object
---@field m__Raw__id FIN.UUID
---@field m__Raw__obj Satisfactory.Components.Object?
---@overload fun(id: FIN.UUID) : Core.Reference
local Reference = {}

---@private
---@param id FIN.UUID
function Reference:__init(id)
    self.m__Raw__id = id
end

---@return boolean
function Reference:Raw__IsValid()
    if not self.m__Raw__obj then
        return false
    end

    local success = pcall(function() local _ = self.m__Raw__obj.hash end)
    return success
end

---@return boolean notFound
function Reference:Raw__Refresh()
    local component = component.proxy(self.m__Raw__id)
    ---@cast component Satisfactory.Components.Object?
    self.m__Raw__obj = component
    return self.m__Raw__obj == nil
end

-- Throws an error if the reference is invalid and could not be refreshed
function Reference:Raw__Check()
    if self:Raw__IsValid() then
        return
    end

    if self:Raw__Refresh() then
        error("Reference is invalid and could not be refreshed", 3)
    end
end

---@private
function Reference:__index(key)
    self:Raw__Check()
    return self.m__Raw__obj[key]
end

---@private
function Reference:__newindex(key, value)
    self:Raw__Check()
    self.m__Raw__obj[key] = value
end

return Utils.Class.CreateClass(Reference, "Core.Reference")
