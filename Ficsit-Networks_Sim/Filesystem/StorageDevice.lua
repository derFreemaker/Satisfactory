---@alias Ficsit_Networks_Sim.Filesystem.StorageDevice.Type
---|"drive" stays and will not be deleted by the simulator
---|"tmpfs" will be deleted when simulator stops or resets 

---@class Ficsit_Networks_Sim.Filesystem.StorageDevice
---@field Id string
---@field Type Ficsit_Networks_Sim.Filesystem.StorageDevice.Type
local StorageDevice = {}
StorageDevice.__index = StorageDevice

---@param id string
---@param storageDeviceType Ficsit_Networks_Sim.Filesystem.StorageDevice.Type
function StorageDevice.new(id, storageDeviceType)
    return setmetatable({
        Id = id,
        Type = storageDeviceType
    }, StorageDevice)
end

return StorageDevice