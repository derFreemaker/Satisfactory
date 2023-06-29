local args = table.pack(...)
---@type Ficsit_Networks_Sim.Filesystem.FileSystemManager
local FileSystemManager = args[1]
local Tools = require("Ficsit-Networks_Sim.Utils.Tools")

local Path = require("Ficsit-Networks_Sim.Filesystem.Path")
local File = require("Ficsit-Networks_Sim.Filesystem.File")

---@class Ficsit_Networks_Sim.filesystem
---@field private fileManager Ficsit_Networks_Sim.Filesystem.FileSystemManager
local filesystem = {}

---@param path string
---@return boolean success
function filesystem.initFileSystem(path)
    Tools.CheckParameterType(path, "string")
    return FileSystemManager:InitFileSystem(path)
end

---@param fsType Ficsit_Networks_Sim.Filesystem.FilesystemEntity.Type
---@param name string
---@return boolean success
function filesystem.makeFileSystem(fsType, name)
    Tools.CheckParameterType(fsType, "string", 1)
    Tools.CheckParameterType(name, "string", 2)
    return FileSystemManager:MakeFileSystem(name, fsType)
end

---@param name string
---@return boolean success
function filesystem.removeFileSystem(name)
    Tools.CheckParameterType(name, "string")
    return FileSystemManager:RemoveFileSystem(name)
end

---@param device string
---@param mountPoint string
---@return boolean success
function filesystem.mount(device, mountPoint)
    Tools.CheckParameterType(device, "string", 1)
    Tools.CheckParameterType(mountPoint, "string", 2)
    return FileSystemManager:Mount(device, mountPoint)
end

---@param device string
---@return boolean success
function filesystem.unmount(device)
    Tools.CheckParameterType(device, "string")
    return FileSystemManager:Unmount(device)
end

---@param path string
---@param mode Ficsit_Networks_Sim.Filesystem.openmode
---@return Ficsit_Networks_Sim.Filesystem.File File
function filesystem.open(path, mode)
    Tools.CheckParameterType(path, "string", 1)
    Tools.CheckParameterType(mode, "string", 2)
    path = FileSystemManager:GetPath(path)
    return File.new(path, mode)
end

---@param path string
---@return boolean success
function filesystem.createDir(path)
    Tools.CheckParameterType(path, "string")
    path = FileSystemManager:GetPath(path)
    local success = os.execute("mkdir \"" .. path .. "\"")
    return (success or false)
end

---@param path string
---@return boolean success
function filesystem.remove(path)
    Tools.CheckParameterType(path, "string")
    path = FileSystemManager:GetPath(path)
    return os.remove(path)
end

---@param from string
---@param to string
---@return boolean success
function filesystem.move(from, to)
    Tools.CheckParameterType(from, "string", 1)
    Tools.CheckParameterType(to, "string", 2)
    from = FileSystemManager:GetPath(from)
    to = FileSystemManager:GetPath(to)
    return os.rename(from, to)
end

---@param from string
---@param to string
---@return boolean success
function filesystem.rename(from, to)
    Tools.CheckParameterType(from, "string", 1)
    Tools.CheckParameterType(to, "string", 2)
    from = FileSystemManager:GetPath(from)
    to = FileSystemManager:GetPath(to)
    return os.rename(from, to)
end

---@param path string
---@return string[] children
function filesystem.children(path)
    Tools.CheckParameterType(path, "string")
    path = FileSystemManager:GetPath(path)
    local result = io.popen("dir \"" .. path .. "\" /b /o")
    if result == nil then
        return {}
    end
    ---@type string[]
    local childs = {}
    for line in result:lines() do
        table.insert(childs, line)
    end
    return childs
end

---@param path string
---@return string[] childs
function filesystem.childs(path)
    Tools.CheckParameterType(path, "string")
    return filesystem.children(path)
end

---@param path string
---@return boolean exists
function filesystem.exists(path)
    Tools.CheckParameterType(path, "string")
    path = FileSystemManager:GetPath(path)
    return os.rename(path, path)
end

---@param path string
---@return boolean isFile
function filesystem.isFile(path)
    Tools.CheckParameterType(path, "string")
    path = FileSystemManager:GetPath(path)
    if not os.execute("cd \"" .. path .. "\"") then
        return true
    end
    return false
end

---@param path string
---@return boolean isDirectory
function filesystem.isDir(path)
    Tools.CheckParameterType(path, "string")
    path = FileSystemManager:GetPath(path)
    if os.execute("cd \"" .. path .. "\"") then
        return true
    end
    return false
end

---@param path string
---@return function
function filesystem.loadFile(path)
    Tools.CheckParameterType(path, "string")
    path = FileSystemManager:GetPath(path)
    local func = loadfile(path)
    if not func then
        error("Unable to load file: '" .. path .. "'")
    end
    return func
end

---@param path string
---@return any | nil
function filesystem.doFile(path)
    Tools.CheckParameterType(path, "string")
    return filesystem.loadFile(path)()
end

---@param mode Ficsit_Networks_Sim.Filesystem.Path.Change | string
---@param pathString string | nil
---@return string
function filesystem.path(mode, pathString)
    Tools.CheckParameterType(mode, { "number", "string" }, 1)
    Tools.CheckParameterType(pathString, { "string", "nil" }, 2)
    if type(mode) == "string" then
        pathString = mode
        mode = 0
    end
    ---@cast mode Ficsit_Networks_Sim.Filesystem.Path.Change
    ---@cast pathString string

    local path = Path.new(pathString)

    if mode == 0 then
        return path:Normalize():GetPath()
    elseif mode == 1 then
        return path:Absolute():GetPath()
    elseif mode == 2 then
        return path:Relative():GetPath()
    elseif mode == 3 then
        return path:GetFileName()
    elseif mode == 4 then
        return path:GetFileStem()
    elseif mode == 5 then
        return path:GetFileExtension();
    end
    error("Using undefined mode: '" .. tostring(mode) .. "'", 2)
end

---@param pathString string[]
---@return integer[]
function filesystem.analyzePath(pathString)
    Tools.CheckParameterType(pathString, "string")
    error("What Why?! Dont use this function.", 2)
end

---@param nodes string[]
---@return boolean[]
function filesystem.isNode(nodes)
    Tools.CheckParameterType(nodes, "table")
    ---@type boolean[]
    local checked = {}
    for key, value in pairs(nodes) do
        checked[key] = Path.IsNode(value)
    end
    return checked
end

return filesystem