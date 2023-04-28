local File = require("FileSystem.File")
local Folder = require("FileSystem.Folder")

---@class BundlerFileSystem
---@field File File
---@field Folder Folder
local BundlerFileSystem = {}
BundlerFileSystem.__index = BundlerFileSystem

BundlerFileSystem.File = File
BundlerFileSystem.Folder = Folder

---@param path string
---@return File
function BundlerFileSystem.getFile(path)
    return File.new(path)
end

---@param path string
---@return Folder
function BundlerFileSystem.getFolder(path)
    return Folder.new(path)
end

---@return string
function BundlerFileSystem.get_script_path()
    local info = debug.getinfo(2, 'S');
    local script_path = info.source:match [[^@?(.*[\/])[^\/]-$]]
    return script_path
end

return BundlerFileSystem
