local File = require("FileSystem.File")

---@class Folder
---@field Name string
---@field Path string
---@field Files File[]
---@field Folders Folder[]
local Folder = {}
Folder.__index = Folder

---@param path string
---@return string
function Folder.GetName(path)
    return path:match(".+%/(.+)$")
end

---@param path string
---@return Folder
function Folder.new(path)
    return setmetatable({
        Name = Folder.GetName(path),
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
    for folderName in popen('dir "' .. self.Path .. '" /d /b /o'):lines() do
        ---@cast folderName string
        table.insert(folders, Folder.new(self.Path .. folderName))
    end
    self.Folders = folders
end

function Folder:Scan()
    self:ScanForFolders()
    self:ScanForFiles()
end

return Folder