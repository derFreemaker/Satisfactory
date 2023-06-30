local ClassManipulation = require("Ficsit-Networks_Sim.Utils.ClassManipulation")
local Object = require("Ficsit-Networks_Sim.Component.Entities.Object")

---@alias Ficsit_Networks_Sim.Computer.PCIDevice.Types string
---|"'FINComputerGPU'"
---|"'FINInternetCard'"
---|"'NetworkCard'"
local PCIDeviceTypes = {
    "FINComputerGPU",
    "FINInternetCard",
    "NetworkCard"
}

---@class Ficsit_Networks_Sim.Computer.PCIDevice : Ficsit_Networks_Sim.Component.Entities.Object
---@field Id string
local PCIDevice = ClassManipulation.useBase({
    type = "PCIDevice"
}, Object.new())
PCIDevice.__index = PCIDevice

---@param id string
---@param obj Ficsit_Networks_Sim.Component.Entities.Object
---@return Ficsit_Networks_Sim.Computer.PCIDevice
function PCIDevice.new(id, obj)
    for _, value in ipairs(PCIDeviceTypes) do
        if obj:GetType() == value then
            break
        end
        error("You can not use this obj as an PCIDevice with Type: '".. obj:GetType() .."'")
    end
    return ClassManipulation.useBase(setmetatable({ Id = id }, PCIDevice), obj)
end

return PCIDevice