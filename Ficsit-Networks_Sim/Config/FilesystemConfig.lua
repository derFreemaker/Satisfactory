local Tools = require("Ficsit-Networks_Sim.Utils.Tools")
local StorageDevice = require("Ficsit-Networks_Sim.Filesystem.StorageDevice")

---@class Ficsit_Networks_Sim.Filesystem.Config
---@field FileSystemPath string
---@field private storageDevices Array<Ficsit_Networks_Sim.Filesystem.StorageDevice>
local FileSystemConfig = {}
FileSystemConfig.__index = FileSystemConfig

---@param dataPath Ficsit_Networks_Sim.Filesystem.Path
function FileSystemConfig.new(dataPath)
    return setmetatable({
        storageDevices = {},
        FileSystemPath = dataPath
            :Extend("Filesystem")
            :GetPath()
    }, FileSystemConfig)
end

---@param id string
---@param type Ficsit_Networks_Sim.Filesystem.StorageDevice.Type | nil
---@return Ficsit_Networks_Sim.Filesystem.Config
function FileSystemConfig:AddStorageDevice(id, type)
    Tools.CheckParameterType(id, "string", 1)
    Tools.CheckParameterType(type, { "string", "nil" }, 2)
    type = type or "drive"
    for _, storageDevice in pairs(self.storageDevices) do
        if storageDevice.Id == id then
            error("Unable to add device with same id: '".. id .."'", 2)
        end
    end
    table.insert(self.storageDevices, StorageDevice.new(id, type))
    return self
end

---@return Array<Ficsit_Networks_Sim.Filesystem.StorageDevice>
function FileSystemConfig:GetStorageDevices()
    return Tools.Table.Copy(self.storageDevices)
end

return FileSystemConfig