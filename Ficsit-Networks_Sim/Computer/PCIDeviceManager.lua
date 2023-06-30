local Tools = require("Ficsit-Networks_Sim.Utils.Tools")

---@class Ficsit_Networks_Sim.Computer.PCIDeviceManager
---@field PCIDevices Array<Ficsit_Networks_Sim.Computer.PCIDevice>
local PCIDeviceManager = {}
PCIDeviceManager.__index = PCIDeviceManager

---@param config Ficsit_Networks_Sim.Computer.Config
---@return Ficsit_Networks_Sim.Computer.PCIDeviceManager
function PCIDeviceManager.new(config)
    return setmetatable({
        PCIDevices = config.PCIDevices
    }, PCIDeviceManager)
end

---@param pciDevice Ficsit_Networks_Sim.Computer.PCIDevice
---@return Ficsit_Networks_Sim.Computer.PCIDeviceManager
function PCIDeviceManager:AddPCIDevice(pciDevice)
    for _, deivce in ipairs(self.PCIDevices) do
        if deivce.Id == pciDevice.Id then
            error("Unable to add two PCIDevices with the same Id: '".. pciDevice.Id .."'", 2)
        end
    end
    table.insert(self.PCIDevices, pciDevice)
    return self
end

---@param id string
---@return boolean
function PCIDeviceManager:RemovePCIDevice(id)
    for index, pciDevice in ipairs(self.PCIDevices) do
        if pciDevice.Id == id then
            table.remove(self.PCIDevices, index)
            return true
        end
    end
    return false
end

---@return Array<Ficsit_Networks_Sim.Computer.PCIDevice>
function PCIDeviceManager:GetPCIDevices()
    return Tools.Table.Copy(self.PCIDevices)
end

---@param dType Ficsit_Networks_Sim.Computer.PCIDevice.Types
---@return Array<Ficsit_Networks_Sim.Computer.PCIDevice>
function PCIDeviceManager:GetPCIDevicesByType(dType)
    ---@type Array<Ficsit_Networks_Sim.Computer.PCIDevice>
    local found = {}
    for _, pciDevice in ipairs(self.PCIDevices) do
        if pciDevice:GetType() == dType then
            table.insert(found, pciDevice)
        end
    end
    return found
end

return PCIDeviceManager