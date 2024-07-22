local Cache = require("Core.Common.Cache")

---@type Core.Cache<string, Core.PCIDeviceRef>
local PCIDeviceRefCache = Cache(nil, true)

---@class Core.PCIDeviceRef<T> : object, Core.Ref<T>
---@field m_class FIN.PCIDevice
---@field m_index integer
---@overload fun(class: FIN.PCIDevice, index: integer) : Core.PCIDeviceRef
local PCIDeviceReference = {}

---@private
---@param class FIN.PCIDevice
---@param index integer
---@return Core.PCIDeviceRef | nil
function PCIDeviceReference:__preinit(class, index)
    return PCIDeviceRefCache:Get(tostring(class) .. "_" .. index)
end

---@private
---@param class FIN.PCIDevice
---@param index integer
function PCIDeviceReference:__init(class, index)
    self.m_class = class
    self.m_index = index

    PCIDeviceRefCache:Add(tostring(class) .. "_" .. index, self)
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
    { Inherit = require("Core.Reference.Reference") })
