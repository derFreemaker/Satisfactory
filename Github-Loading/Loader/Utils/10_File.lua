---@class Utils.File
local File = {}

---@type table<string, FIN.Filesystem.File>
local OpenFiles = {}

---@return string key
local function getUniqeKey(key)
    if OpenFiles[key] then
        return getUniqeKey(key .. "$")
    end

    return key
end

local OpenFileFunc = filesystem.open

---@class Uitls.File.WrappedFile : FIN.Filesystem.File
---@field private m_file FIN.Filesystem.File
---@field private m_openFilesKey string
local WrappedFile = {}

---@package
---@param path string
---@param mode FIN.Filesystem.openmode
---@return FIN.Filesystem.File
function WrappedFile.new(path, mode)
    local key = getUniqeKey(path)

    local instance = setmetatable({
        m_file = OpenFileFunc(path, mode),
        m_openFilesKey = key,
    }, { __index = WrappedFile })

    OpenFiles[key] = instance
    return instance
end

function WrappedFile:read(length)
    return self.m_file:read(length)
end

function WrappedFile:seek(offset)
    self.m_file:seek(offset)
end

function WrappedFile:write(data)
    self.m_file:write(data)
end

function WrappedFile:close()
    self.m_file:close()
    OpenFiles[self.m_openFilesKey] = nil
end

filesystem.open = WrappedFile.new

---@alias Utils.File.writeModes
---|"w" write -> file stream can read and write creates the file if it doesn’t exist
---|"a" end of file -> file stream can read and write cursor is set to the end of file
---|"+r" truncate -> file stream can read and write all previous data in file gets dropped
---|"+a" append -> file stream can read the full file but can only write to the end of the existing file

---@param path string
---@param mode Utils.File.writeModes
---@param data string?
---@param createPath boolean?
function File.Write(path, mode, data, createPath)
    data = data or ""
    createPath = createPath or false

    local fileName = filesystem.path(3, path)
    local folderPath = path:gsub(fileName, "")
    if not filesystem.exists(folderPath) then
        if not createPath then
            error("folder does not exists: '" .. folderPath .. "'", 2)
        end
        filesystem.createDir(folderPath)
    end

    local file = filesystem.open(path, mode)
    file:write(data)
    file:close()
end

---@param path string
---@return string?
function File.ReadAll(path)
    if not filesystem.exists(path) then
        return nil
    end
    local file = filesystem.open(path, "r")
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

---@param path string
function File.Clear(path)
    if not filesystem.exists(path) then
        return
    end
    local file = filesystem.open(path, "w")
    file:write("")
    file:close()
end

return File, OpenFiles
