---@class Core.PCIDeviceReference : object
---@field m__Raw__class FIN.Class
---@field m__Raw__index integer
---@field m__Raw__obj Satisfactory.Components.Object?
---@overload fun(class: FIN.Class, index: integer) : Core.PCIDeviceReference
local PCIDeviceReference = {}

---@private
---@param class FIN.Class
---@param index integer
function PCIDeviceReference:__init(class, index)
    self.m__Raw__class = class
    self.m__Raw__index = index
end

---@return boolean
function PCIDeviceReference:Raw__IsValid()
    if not self.m__Raw__obj then
        return false
    end

    local success = pcall(function() local _ = self.m__Raw__obj.hash end)
    return success
end

---@return boolean notFound
function PCIDeviceReference:Raw__Refresh()
    self.m__Raw__obj = computer.getPCIDevices(self.m__Raw__class)[self.m__Raw__index]
    return self.m__Raw__obj == nil
end

-- Throws an error if the reference is invalid and could not be refreshed
function PCIDeviceReference:Raw__Check()
    if self:Raw__IsValid() then
        return
    end

    if self:Raw__Refresh() then
        error("Reference is invalid and could not be refreshed", 3)
    end
end

---@private
function PCIDeviceReference:__index(key)
    self:Raw__Check()
    return self.m__Raw__obj[key]
end

---@private
function PCIDeviceReference:__newindex(key, value)
    self:Raw__Check()
    self.m__Raw__obj[key] = value
end

return Utils.Class.CreateClass(PCIDeviceReference, "Core.PCIDeviceReference")
