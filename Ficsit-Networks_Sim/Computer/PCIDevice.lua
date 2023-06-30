local ClassManipulation = require("Ficsit-Networks_Sim.Utils.ClassManipulation")
local Object = require("Ficsit-Networks_Sim.Component.Entities.Object")

---@alias Ficsit_Networks_Sim.Computer.PCIDevice.Types
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
---@field Type Ficsit_Networks_Sim.Computer.PCIDevice.Types
---@field Data table
---@field private instance Ficsit_Networks_Sim.Component.Entities.Object
local PCIDevice = ClassManipulation.useBase({
    type = "PCIDevice"
}, Object.new())
PCIDevice.__index = PCIDevice

---@param id string
---@param obj Ficsit_Networks_Sim.Component.Entities.Object
---@return Ficsit_Networks_Sim.Computer.PCIDevice
function PCIDevice.new(id, obj)
    PCIDevice.CheckPCIDeviceType(obj:GetType())
    local instance = setmetatable({ Id = id }, PCIDevice)
    instance.instance = ClassManipulation.useBase(setmetatable({ Id = id }, PCIDevice), obj)
    return instance
end

---@param id string
---@param dType Ficsit_Networks_Sim.Computer.PCIDevice.Types
---@param data table | nil
function PCIDevice.newAsBuildable(id, dType, data)
    PCIDevice.CheckPCIDeviceType(dType)
    return setmetatable({
        Id = id,
        Type = dType,
        Data = data
    }, PCIDevice)
end

---@param dType Ficsit_Networks_Sim.Computer.PCIDevice.Types
function PCIDevice.CheckPCIDeviceType(dType)
    for _, value in ipairs(PCIDeviceTypes) do
        if dType == value then
            return
        end
    end
    error("You can not use this obj as an PCIDevice with Type: '" .. dType .. "'", 3)
end

---@param componentManager Ficsit_Networks_Sim.Component.ComponentManager
function PCIDevice:Build(componentManager)
    if not self.instance then
        self.instance = componentManager:GetComponentClass(self.Type)
    end
    return self.instance.newWithData((self.Data or {}))
end

return PCIDevice