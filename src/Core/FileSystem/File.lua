local Path = require("Core.FileSystem.Path")

---@alias Core.FileSystem.File.OpenModes
---|"r" read only -> file stream can just read from file. If file doesn’t exist, will return nil
---|"w" write -> file stream can read and write creates the file if it doesn’t exist
---|"a" end of file -> file stream can read and write cursor is set to the end of file
---|"+r" truncate -> file stream can read and write all previous data in file gets dropped
---|"+a" append -> file stream can read the full file but can only write to the end of the existing file

---@class Core.FileSystem.File : object
---@field private m_path Core.FileSystem.Path
---@field private m_mode Core.FileSystem.File.OpenModes?
---@field private m_file FIN.Filesystem.File?
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
        self.m_path = Path(path)
        return
    end

    self.m_path = path
end

---@return string
function File:GetPath()
    return self.m_path:GetPath()
end

---@return boolean exists
function File:Exists()
    return filesystem.exists(self.m_path:GetPath())
end

---@return boolean isOpen
---@nodiscard
function File:IsOpen()
    if not self.m_file then
        return false
    end

    return true
end

---@private
function File:CheckState()
    if not self:IsOpen() then
        error("file is not open: " .. self.m_path:GetPath(), 3)
    end
end

---@param mode Core.FileSystem.File.OpenModes
---@return boolean isOpen
---@nodiscard
function File:Open(mode)
    local file

    if not filesystem.exists(self.m_path:GetPath()) then
        local parentFolder = self.m_path:GetParentFolder()
        if not filesystem.exists(parentFolder) then
            error("parent folder does not exist: " .. parentFolder)
        end

        if mode == "r" then
            file = filesystem.open(self.m_path:GetPath(), "w")
            file:write("")
            file:close()
            file = nil
        end

        return false
    end

    self.m_file = filesystem.open(self.m_path:GetPath(), mode)
    self.m_mode = mode

    return true
end

---@param data string
function File:Write(data)
    self:CheckState()

    self.m_file:write(data)
end

---@param length integer
function File:Read(length)
    self:CheckState()

    return self.m_file:read(length)
end

---@param offset integer
function File:Seek(offset)
    self:CheckState()

    self.m_file:seek(offset)
end

function File:Close()
    self.m_file:close()
    self.m_file = nil
end

function File:Clear()
    local isOpen = self:IsOpen()
    if isOpen then
        self:Close()
    end

    if not filesystem.exists(self.m_path:GetPath()) then
        return
    end

    filesystem.remove(self.m_path:GetPath())

    local file = filesystem.open(self.m_path:GetPath(), "w")
    file:write("")
    file:close()

    if isOpen then
        self.m_file = filesystem.open(self.m_path:GetPath(), self.m_mode)
    end
end

return Utils.Class.CreateClass(File, "Core.FileSystem.File")
