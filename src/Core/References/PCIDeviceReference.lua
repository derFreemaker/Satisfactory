---@class Core.PCIDeviceReference<T> : object, Core.Reference<T>
---@field m_class FIN.PCIDevice
---@field m_index integer
---@overload fun(class: FIN.PCIDevice, index: integer) : Core.PCIDeviceReference
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
    local pciDevices = computer.getPCIDevices(self.m_class)
    if #pciDevices == 0 then
        return false
    end

    local pciDevice = pciDevices[self.m_index]
    self.m_obj = pciDevice
    return pciDevice ~= nil
end

return class("Core.PCIDeviceReference", PCIDeviceReference,
    { Inherit = require("Core.References.Reference") })
