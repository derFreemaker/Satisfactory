---@class File
---@field Path string
local File = {}
File.__index = File

---@param path string
---@return File
function File.new(path)
    return setmetatable({
        Path = path
    }, File)
end

function File:Create()
    local stream = self:GetFileStream("w")
    if stream == nil then
        return
    end
    stream:close()
end

---@param mode openmode
---@return file* | nil
function File:GetFileStream(mode)
    return io.open(self.Path, mode)
end

---@return string | nil, boolean
function File:ReadFile()
    local stream = self:GetFileStream("r")
    if stream == nil then
        return nil, false
    end
    local content = stream:read("a")
    stream:close()
    return content, true
end

---@param content string
---@return boolean
function File:Write(content)
    local stream = self:GetFileStream("w")
    if stream == nil then
        return false
    end
    stream:write(content)
    stream:close()
    return true
end

---@param content string
---@return boolean
function File:Append(content)
    local stream = self:GetFileStream("a")
    if stream == nil then
        return false
    end
    stream:write(content)
    stream:close()
    return true
end



---@class Folder
---@field Path string
---@field Files string[]
---@field Folders Folder[]
local Folder = {}
Folder.__index = Folder

---@param path string
---@return Folder
function Folder.new(path)
    return setmetatable({
        Path = path
    }, Folder)
end

function Folder:ScanForFiles()
    ---@type string[], function
    local files, popen = {}, io.popen
    for fileName in popen('dir "' .. self.Path .. '" /a-d /b /o'):lines() do
        ---@cast fileName string
        table.insert(files, File.new(self.Path .. fileName))
    end
    self.Files = files
end

function Folder:ScanForFolders()
    ---@type Folder[], function
    local folders, popen = {}, io.popen
    for folderName in popen('dir "' .. self.Path .. '" /a-d /b /o'):lines() do
        ---@cast folderName string
        table.insert(folders, Folder.new(self.Path .. folderName))
    end
    self.Folders = folders
end

function Folder:Scan()
    self:ScanForFolders()
    self:ScanForFiles()
end



---@class FileSystem
local FileSystem = {}
FileSystem.__index = FileSystem

---@param path string
---@return File
function FileSystem.getFile(path)
    return File.new(path)
end

---@param path string
---@return Folder
function FileSystem.getFolder(path)
    return Folder.new(path)
end

---@return string
function FileSystem.get_script_path()
    local info = debug.getinfo(2, 'S');
    local script_path = info.source:match [[^@?(.*[\/])[^\/]-$]]
    return script_path
end

return FileSystem
