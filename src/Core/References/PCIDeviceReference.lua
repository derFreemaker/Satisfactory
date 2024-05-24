---@class Core.PCIDeviceReference<T> : object, Core.IReference<T>
---@field m_class FIN.PCIDevice
---@field m_index integer
---@overload fun(class: FIN.Class, index: integer) : Core.PCIDeviceReference
local PCIDeviceReference = {}
return class("Core.PCIDeviceReference", PCIDeviceReference, { Inherit = require("Core.References.IReference") },
    function()
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
    end)
