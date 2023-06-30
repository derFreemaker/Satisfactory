local args = table.pack(...)
---@type Ficsit_Networks_Sim.Simulator
local Simulator = args[1]
---@type Ficsit_Networks_Sim.Computer.EEPROMManager
local EEPROMManager = args[2]
---@type Ficsit_Networks_Sim.Computer.PCIDeviceManager
local PCIDeviceManager = args[3]

local Tools = require("Ficsit-Networks_Sim.Utils.Tools")

---@class Ficsit_Networks_Sim.computer
local computer = {
    PCIDevices = {}
}

-- //TODO: computer.getInstance()
function computer.getInstance()
    error("Why would you use this?", 2)
end

function computer.reset()
    Simulator:Reset()
end

function computer.stop()
    Simulator:Stop(1, "stop")
end

---@param error string |nil
function computer.panic(error)
    local errorString = tostring(error)
    errorString = "!Panic: ".. errorString
    Simulator:Stop(0, errorString)
end

--- Doesn't do anything in here
function computer.skip() end

--- Doesn't do anything in here
function computer.promote() end

--- Doesn't do anything in here
function computer.demote() end

--- Returning 0 because would return 1 when is running async some how.
--- Not possible in here though.
---@return integer
function computer.state()
    return 0
end

---@param pitch number
function computer.beep(pitch)
    Tools.CheckParameterType(pitch, "number")
end

---@return string
function computer.getEEPROM()
    return EEPROMManager:getEEPROM()
end

--- You have to restart or reset the computer to apply changes.
---@param EEPROM string
function computer.setEEPROM(EEPROM)
    Tools.CheckParameterType(EEPROM, "string")
    EEPROMManager:setEEPROM(EEPROM)
end

---@return number
function computer.time()
    return os.time()
end

---@return integer
function computer.millis()
    return os.clock()
end

function computer.magicTime()
    return os.time, os.date(), os.date("!%Y-%m-%d %H:%M:%S")
end

---@param typeToGet Ficsit_Networks_Sim.Computer.PCIDevice.Types | Ficsit_Networks_Sim.Component.Entities.Object
---@return table
function computer.getPCIDevices(typeToGet)
    Tools.CheckParameterType(typeToGet, { "string", "table" })
    if type(typeToGet) == "table" then
        typeToGet = typeToGet:GetType()
        ---@cast typeToGet string
    end
    return PCIDeviceManager:GetPCIDevicesByType(typeToGet)
end

return computer