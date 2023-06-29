---@class Ficsit_Networks_Sim.Filesystem.MountedDevice
---@field Id string
---@field MountPoint string
local MountedDevice = {}
MountedDevice.__index = MountedDevice

---@param id string
---@param mountPoint string
---@return Ficsit_Networks_Sim.Filesystem.MountedDevice
function MountedDevice.new(id, mountPoint)
    if mountPoint:find("/") ~= 1 then
        mountPoint = "/" .. mountPoint
    end
    return setmetatable({
        Id = id,
        MountPoint = mountPoint
    }, MountedDevice)
end

---@param fileSystemPath Ficsit_Networks_Sim.Filesystem.Path
---@return boolean success
function MountedDevice:Setup(fileSystemPath)
    local path = fileSystemPath:Extend(self.Id):GetPath()
    if os.rename(path, path) then
        return true
    end
    local command = "mkdir \"" .. path .. "\""
    return (os.execute(command) or false)
end

---@param fileSystemPath Ficsit_Networks_Sim.Filesystem.Path
---@return boolean success
function MountedDevice:Cleanup(fileSystemPath)
    local command = "rm -r \"".. fileSystemPath:Extend(self.Id):GetPath() .."\""
    return (os.execute(command) or false)
end

return MountedDevice