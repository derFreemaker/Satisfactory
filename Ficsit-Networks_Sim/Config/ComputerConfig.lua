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
---@param obj Ficsit_Networks_Sim.Component.Entities.Object
---@return Ficsit_Networks_Sim.Computer.Config
function ComputerConfig:AddPCIDevice(id, obj)
    Tools.CheckParameterType(id, "string", 1)
    Tools.CheckParameterType(obj, "table", 2)
    local pciDevice = PCIDevice.new(id, obj)
    table.insert(self.PCIDevices, pciDevice)
    return self
end

return ComputerConfig