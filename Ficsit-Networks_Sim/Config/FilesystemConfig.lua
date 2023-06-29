local StorageDevice = require("Ficsit-Networks_Sim.Filesystem.StorageDevice")

---@class Ficsit_Networks_Sim.Filesystem.Config
---@field StorageDevices Array<Ficsit_Networks_Sim.Filesystem.StorageDevice>
local Config = {}
Config.__index = Config

function Config.new()
    return setmetatable({
        storageDevices = {}
    }, Config)
end

---@param id string
---@param type Ficsit_Networks_Sim.Filesystem.StorageDevice.Type | nil
---@return Ficsit_Networks_Sim.Filesystem.Config
function Config:AddStorageDevice(id, type)
    type = type or "drive"
    for _, storageDevice in pairs(self.StorageDevices) do
        if storageDevice.Id == id then
            error("Unable to add device with same id: '".. id .."'", 2)
        end
    end
    table.insert(self.StorageDevices, StorageDevice.new(id, type))
    return self
end

return Config