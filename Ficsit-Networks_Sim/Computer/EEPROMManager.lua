---@class Ficsit_Networks_Sim.Computer.EEPROMManager
---@field private path string
local EEPROMManager = {}
EEPROMManager.__index = EEPROMManager

---@param path string
---@return Ficsit_Networks_Sim.Computer.EEPROMManager
function EEPROMManager.new(path)
    return setmetatable({
        path = path
    }, EEPROMManager)
end

---@param data string
function EEPROMManager:setEEPROM(data)
    local file = io.open(self.path, "w")
    if file == nil then
        error("Unable to open EEPROM file: '" .. self.path .. "'", 2)
    end
    file:write(data)
    file:close()
end

---@return string
function EEPROMManager:getEEPROM()
    local file = io.open(self.path, "r")
    if file == nil then
        error("Unable to open EEPROM file: '" .. self.path .. "'", 2)
    end
    local data = file:read("a")
    file:close()
    return data
end

---@return function
function EEPROMManager:GetEEPROMFunc()
    if not self.path or self.path == "" then
        error("no Path for EEPROM given", 2)
    end
    local func, errmsg = loadfile(self.path)
    if func == nil then
        error("Unable to load EEPROM: '" .. errmsg .. "'", 2)
    end
    return func
end

return EEPROMManager