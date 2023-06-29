---@alias Ficsit_Networks_Sim.Filesystem.openmode string
---|"r" read only -> file stream can just read from file. If file doesn’t exist, open will return nil
---|"w" write -> file stream can read and write creates the file if it doesn’t exist
---|"a" end of file -> file stream can read and write cursor is set to the end of file
---|"+r" truncate -> file stream can read and write all previous data in file gets dropped
---|"+a" append -> file stream can read the full file but can only write to the end of the existing file

---@class Ficsit_Networks_Sim.Filesystem.File
---@field private fileStream file* | nil
local File = {}
File.__index = File

---@param path string
---@param mode Ficsit_Networks_Sim.Filesystem.openmode
---@return Ficsit_Networks_Sim.Filesystem.File File
function File.new(path, mode)
    ---@type file*?
    local fileStream = {}
    if mode == "r" or mode == "w" then
        ---@cast mode string
        fileStream = io.open(path, mode)
    elseif mode == "a" then
        fileStream = io.open(path, "a+")
        if fileStream == nil then
            error("Unable to open file: '" .. path .. "'", 3)
        end
        fileStream:seek("end")
    elseif mode == "+r" then
        fileStream = io.open(path, "w+")
    elseif mode == "+a" then
        fileStream = io.open(path, "a+")
    end

    return setmetatable({
        fileStream = fileStream
    }, File)
end

---@param data string
function File:write(data)
    if self.fileStream == nil then
        error("filestream not open", 2)
    end
    self.fileStream:write(data)
end

---@param size integer
---@return string
function File:read(size)
    if self.fileStream == nil then
        error("filestream not open", 2)
    end
    return tostring(self.fileStream:read(size))
end

---@param pos integer
function File:seek(pos)
    if self.fileStream == nil then
        error("filestream not open", 2)
    end
    return self.fileStream:seek("cur", pos)
end

function File:close()
    if self.fileStream == nil then
        error("filestream not open", 2)
    end
    return self.fileStream:close()
end

return File