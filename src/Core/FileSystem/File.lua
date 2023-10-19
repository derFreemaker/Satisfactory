local Path = require("Core.FileSystem.Path")

---@alias Core.FileSystem.File.OpenModes
---|"r" read only -> file stream can just read from file. If file doesn’t exist, will return nil
---|"w" write -> file stream can read and write creates the file if it doesn’t exist
---|"a" end of file -> file stream can read and write cursor is set to the end of file
---|"+r" truncate -> file stream can read and write all previous data in file gets dropped
---|"+a" append -> file stream can read the full file but can only write to the end of the existing file

---@class Core.FileSystem.File : object
---@field private _Path Core.FileSystem.Path
---@field private _Mode Core.FileSystem.File.OpenModes?
---@field private _File FIN.Filesystem.File?
---@overload fun(path: string | Core.FileSystem.Path) : Core.FileSystem.File
local File = {}

---@param path Core.FileSystem.Path | string
---@param data string
function File.Static__WriteAll(path, data)
    if type(path) == "string" then
        path = Path(path)
    end

    if not filesystem.exists(path:GetParentFolder()) then
        error("parent folder does not exist: " .. path:GetParentFolder())
    end

    local file = filesystem.open(path:GetPath(), "w")
    file:write(data)
    file:close()
end

---@param path Core.FileSystem.Path | string
---@return string
function File.Static__ReadAll(path)
    if type(path) == "string" then
        path = Path(path)
    end

    if not filesystem.exists(path:GetPath()) then
        error("file does not exist: " .. path:GetParentFolder())
    end

    local file = filesystem.open(path:GetPath(), "r")

    local str = ""
    while true do
        local buf = file:read(8192)
        if not buf then
            break
        end
        str = str .. buf
    end

    file:close()
    return str
end

---@private
---@param path string | Core.FileSystem.Path
function File:__init(path)
    if type(path) == "string" then
        self._Path = Path(path)
        return
    end

    self._Path = path
end

---@return string
function File:GetPath()
    return self._Path:GetPath()
end

---@return boolean exists
function File:Exists()
    return filesystem.exists(self._Path:GetPath())
end

---@return boolean isOpen
---@nodiscard
function File:IsOpen()
    if not self._File then
        return false
    end

    return true
end

---@private
function File:CheckState()
    if not self:IsOpen() then
        error("file is not open: " .. self._Path:GetPath(), 3)
    end
end

---@param mode Core.FileSystem.File.OpenModes
---@return boolean isOpen
---@nodiscard
function File:Open(mode)
    local file

    if not filesystem.exists(self._Path:GetPath()) then
        local parentFolder = self._Path:GetParentFolder()
        if not filesystem.exists(parentFolder) then
            error("parent folder does not exist: " .. parentFolder)
        end

        if mode == "r" then
            file = filesystem.open(self._Path:GetPath(), "w")
            file:write("")
            file:close()
            file = nil
        end

        return false
    end

    self._File = filesystem.open(self._Path:GetPath(), mode)
    self._Mode = mode

    return true
end

---@param data string
function File:Write(data)
    self:CheckState()

    self._File:write(data)
end

---@param length integer
function File:Read(length)
    self:CheckState()

    return self._File:read(length)
end

---@param offset integer
function File:Seek(offset)
    self:CheckState()

    self._File:seek(offset)
end

function File:Close()
    self._File:close()
    self._File = nil
end

function File:Clear()
    local isOpen = self:IsOpen()
    if isOpen then
        self:Close()
    end

    if not filesystem.exists(self._Path:GetPath()) then
        return
    end

    filesystem.remove(self._Path:GetPath())

    local file = filesystem.open(self._Path:GetPath(), "w")
    file:write("")
    file:close()

    if isOpen then
        self._File = filesystem.open(self._Path:GetPath(), self._Mode)
    end
end

return Utils.Class.CreateClass(File, "Core.FileSystem.File")
