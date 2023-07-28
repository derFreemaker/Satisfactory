local ClassManipulation = require("Ficsit-Networks_Sim.Utils.ClassManipulation")
local Object = require("Ficsit-Networks_Sim.Component.Entities.Object")

---@class Ficsit_Networks_Sim.Computer.PCIDevice : Ficsit_Networks_Sim.Component.Entities.Object
---@field Id string
---@field Type Ficsit_Networks_Sim.Component.PCIDeviceTypes
---@field Data table
---@field private instance Ficsit_Networks_Sim.Component.Entities.Object
local PCIDevice = ClassManipulation.CreateSubclass(Object, "PCIDevice")
PCIDevice.__index = PCIDevice

---@param id string
---@param obj Ficsit_Networks_Sim.Component.Entities.Object
---@return Ficsit_Networks_Sim.Computer.PCIDevice
function PCIDevice.new(id, obj)
    PCIDevice.CheckPCIDeviceType(obj)
    local instance = setmetatable({ Id = id }, PCIDevice)
    instance.instance = ClassManipulation.UseBase(setmetatable({ Id = id }, PCIDevice), obj)
    return instance
end

---@param id string
---@param dType Ficsit_Networks_Sim.Component.PCIDeviceTypes
---@param data table | nil
function PCIDevice.newAsBuildable(id, dType, data)
    return setmetatable({
        Id = id,
        Type = dType,
        Data = data
    }, PCIDevice)
end

---@param obj Ficsit_Networks_Sim.Component.Entities.Object
---@param errorLevel integer | nil
function PCIDevice.CheckPCIDeviceType(obj, errorLevel)
    errorLevel = errorLevel or 3
    if ClassManipulation.IsClassOfType(obj, "FINComputerModule") then
        return
    end
    error("You can not use this obj as an PCIDevice with Type: '" .. obj:GetType() .. "'", errorLevel)
end

---@param componentManager Ficsit_Networks_Sim.Component.ComponentManager
function PCIDevice:Build(componentManager)
    if not self.instance then
        self.instance = componentManager:GetComponentClass(self.Type)
        PCIDevice.CheckPCIDeviceType(self.instance)
    end
    return self.instance(self.Data or {})
end

return PCIDevice