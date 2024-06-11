---@class Core.PCIDeviceReference<T> : object, Core.Reference<T>
---@field m_class FIN.PCIDevice
---@field m_index integer
---@overload fun(class: FIN.Class, index: integer) : Core.PCIDeviceReference
local PCIDeviceReference = {}

---@private
---@param class FIN.PCIDevice
---@param index integer
function PCIDeviceReference:__init(class, index)
    self.m_class = class
    self.m_index = index
end

---@return boolean found
function PCIDeviceReference:Fetch()
    local obj = computer.getPCIDevices(self.m_class)[self.m_index]
    self.m_obj = obj
    return obj ~= nil
end

return class("Core.PCIDeviceReference", PCIDeviceReference,
    { Inherit = require("Core.References.Reference") })
