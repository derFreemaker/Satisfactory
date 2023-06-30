local Path = require("Ficsit-Networks_Sim.Filesystem.Path")
local FilesystemEntity = require("Ficsit-Networks_Sim.Filesystem.FilesystemEntity")
local StorageDevice = require("Ficsit-Networks_Sim.Filesystem.StorageDevice")
local MountedDevice = require("Ficsit-Networks_Sim.Filesystem.MountedDevice")

---@class Ficsit_Networks_Sim.Filesystem.FileSystemManager
---@field StorageDevices Array<Ficsit_Networks_Sim.Filesystem.StorageDevice>
---@field private fileSystemFolder Ficsit_Networks_Sim.Filesystem.Path
---@field private mainFileSystem Ficsit_Networks_Sim.Filesystem.FilesystemEntity
---@field private mountedDevices Array<Ficsit_Networks_Sim.Filesystem.MountedDevice>
---@field private filesystemEntities Array<Ficsit_Networks_Sim.Filesystem.FilesystemEntity>
local FileSystemManager = {}
FileSystemManager.__index = FileSystemManager

---@param id string
---@param config Ficsit_Networks_Sim.Filesystem.Config
---@return Ficsit_Networks_Sim.Filesystem.FileSystemManager
function FileSystemManager.new(id, config)
    local dataFolderPath = Path.new(config.FileSystemPath)
    dataFolderPath:Append(id)
    if not os.rename(dataFolderPath:GetPath(), dataFolderPath:GetPath()) then
        os.execute("mkdir \"" .. dataFolderPath:GetPath() .. "\"")
    end
    return setmetatable({
        fileSystemFolder = dataFolderPath,
        storageDevices = config:GetStorageDevices(),
        mountedDevices = {},
        filesystemEntities = {}
    }, FileSystemManager)
end

---@param path string
---@return boolean success
function FileSystemManager:InitFileSystem(path)
    self.mainFileSystem = FilesystemEntity.new("main", path)
    local currentFolderPath = self.fileSystemFolder:GetPath()
    local success, _ = os.rename(currentFolderPath, currentFolderPath)
    if not success then
        local command = "mkdir \"" .. self.fileSystemFolder .. "\""
        success = (os.execute(command) or false)
    end
    return success
end

---@param name string
---@param type Ficsit_Networks_Sim.Filesystem.FilesystemEntity.Type
---@return boolean success
function FileSystemManager:MakeFileSystem(name, type)
    if type ~= "tmpfs" then
        error("No valid FileSystem Type", 3)
    end
    for _, filesystemEntity in ipairs(self.filesystemEntities) do
        if filesystemEntity.Name == name then
            return false
        end
    end
    local memoryDrive = FilesystemEntity.new(type, name)
    table.insert(self.filesystemEntities, memoryDrive)
    local success = self:AddStorageDevice(memoryDrive.Name, "tmpfs")
    if not success then
        for index, filesystemEntity in ipairs(self.filesystemEntities) do
            if filesystemEntity.Name == memoryDrive.Name then
                table.remove(self.filesystemEntities, index)
            end
        end
    end
    return success
end

---@param name string
---@return boolean success
function FileSystemManager:RemoveFileSystem(name)
    for index, filesystemEntity in ipairs(self.filesystemEntities) do
        if filesystemEntity.Name == name then
            local mountedDevice = self:GetMountedDevice(filesystemEntity.Path)
            if not mountedDevice then
                return false
            end
            local success = mountedDevice:Cleanup(self.fileSystemFolder:Extend(self.mainFileSystem.Path))
            if success then
                table.remove(self.filesystemEntities, index)
            end
            return success
        end
    end
    return false
end

---@param device string
---@param mountPoint string
---@return boolean success
function FileSystemManager:Mount(device, mountPoint)
    for _, mountedDevice in ipairs(self.mountedDevices) do
        if mountedDevice.Id == device or mountedDevice.MountPoint == mountPoint then
            return false
        end
    end
    local deviceName = device:gsub(self.mainFileSystem.Path .. "/", "")
    if not self:GetStorageDevice(deviceName) then
        return false
    end
    local mountedDevice = MountedDevice.new(deviceName, mountPoint)
    if not mountedDevice:Setup(self.fileSystemFolder) then
        return false
    end
    table.insert(self.mountedDevices, mountedDevice)
    return true
end

---@param device string
---@return boolean success
function FileSystemManager:Unmount(device)
    for index, mountedDevice in ipairs(self.mountedDevices) do
        if mountedDevice.Id == device then
            table.remove(self.mountedDevices, index)
            return true
        end
    end
    return false
end

---@param id string
---@return Ficsit_Networks_Sim.Filesystem.MountedDevice | nil
function FileSystemManager:GetMountedDevice(id)
    for _, mountedDevice in ipairs(self.mountedDevices) do
        if mountedDevice.Id == id then
            return mountedDevice
        end
    end
    return nil
end

---@param id string
---@param type Ficsit_Networks_Sim.Filesystem.StorageDevice.Type | nil
---@return boolean success
function FileSystemManager:AddStorageDevice(id, type)
    type = type or "drive"
    for _, storageDevice in pairs(self.StorageDevices) do
        if storageDevice.Id == id then
            return false
        end
    end
    table.insert(self.StorageDevices, StorageDevice.new(id, type))
    return true
end

---@param id string
---@return boolean success
function FileSystemManager:RemoveStorageDevice(id)
    for index, storageDevice in pairs(self.StorageDevices) do
        if storageDevice.Id == id then
            table.remove(self.StorageDevices, index)
            return true
        end
    end
    return false
end

---@param id string
---@return Ficsit_Networks_Sim.Filesystem.StorageDevice | nil
function FileSystemManager:GetStorageDevice(id)
    for _, storageDevice in ipairs(self.StorageDevices) do
        if storageDevice.Id == id then
            return storageDevice
        end
    end
end

---@return Array<Ficsit_Networks_Sim.Filesystem.StorageDevice>
function FileSystemManager:GetStorageDevices()
    ---@type Array<Ficsit_Networks_Sim.Filesystem.StorageDevice>
    local storageDevices = {}
    for _, storageDevice in ipairs(self.StorageDevices) do
        table.insert(storageDevices, storageDevice)
    end
    return storageDevices
end

---@param pathToGet string
---@return string
function FileSystemManager:GetPath(pathToGet)
    local foundDevPos = pathToGet:find(self.mainFileSystem.Path)
    if foundDevPos and foundDevPos < 3 then
        return self.fileSystemFolder:GetPath()
    end
    if pathToGet:find("/") ~= 1 then
        pathToGet = "/" .. pathToGet
    end

    ---@type Array<Ficsit_Networks_Sim.Filesystem.MountedDevice>
    local foundDevices = {}
    for _, mountedDevice in ipairs(self.mountedDevices) do
        if pathToGet:find(mountedDevice.MountPoint) == 1 then
            table.insert(foundDevices, mountedDevice)
        end
    end

    ---@type integer
    local bestMatchLenght = 0
    ---@type Ficsit_Networks_Sim.Filesystem.MountedDevice
    local bestMatchMountedDevice = {}
    for _, mountedDevice in ipairs(foundDevices) do
        local mountPointLenght = mountedDevice.MountPoint:len()
        if mountPointLenght > bestMatchLenght then
            bestMatchLenght = mountPointLenght
            bestMatchMountedDevice = mountedDevice
        end
    end

    if bestMatchLenght == 0 then
        error("Unable to convert Path: '" .. pathToGet .. "' no mounted device found", 4)
    end

    local path = self.fileSystemFolder
        :Extend(bestMatchMountedDevice.Id)
        :Extend(pathToGet:gsub(bestMatchMountedDevice.MountPoint, ""))
        :GetPath()
    return path
end

function FileSystemManager:Cleanup()
    for _, filesystemEntity in ipairs(self.filesystemEntities) do
        if filesystemEntity.Type == "tmpfs" then
            local mountedDevice = self:GetMountedDevice(filesystemEntity.Name)
            if mountedDevice then
                mountedDevice:Cleanup(self.fileSystemFolder)
            end
        end
    end
end

return FileSystemManager