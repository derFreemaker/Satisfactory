local Tools = require("Ficsit-Networks_Sim.Utils.Tools")
local PCIDevice = require("Ficsit-Networks_Sim.Computer.PCIDevice")

---@class Ficsit_Networks_Sim.Computer.Config
---@field PCIDevices Array<Ficsit_Networks_Sim.Computer.PCIDevice>
local ComputerConfig = {}
ComputerConfig.__index = ComputerConfig

---@return Ficsit_Networks_Sim.Computer.Config
function ComputerConfig.new()
    return setmetatable({
        PCIDevices = {}
    }, ComputerConfig)
end

---@param id string
---@param dType Ficsit_Networks_Sim.Computer.PCIDevice.Types
---@param data table | nil
---@return Ficsit_Networks_Sim.Computer.Config
function ComputerConfig:AddPCIDevice(id, dType, data)
    Tools.CheckParameterType(id, "string", 1)
    Tools.CheckParameterType(dType, "string", 2)
    Tools.CheckParameterType(data, { "table", "nil" }, 3)
    PCIDevice.CheckPCIDeviceType(dType)
    local pciDevice = PCIDevice.newAsBuildable(id, dType, data)
    table.insert(self.PCIDevices, pciDevice)
    return self
end

return ComputerConfig