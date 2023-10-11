---@class Utils.File
local File = {}

---@type Dictionary<string, FicsIt_Networks.Filesystem.File>
local openFiles = {}

---@return string key
local function getUniqeKey(key)
    if openFiles[key] then
        return getUniqeKey(key .. "$")
    end

    return key
end

local filesystemOpenFunc = filesystem.open
---@param path string
---@param mode FicsIt_Networks.Filesystem.openmode
---@return FicsIt_Networks.Filesystem.File
---@diagnostic disable-next-line
function filesystem.open(path, mode)
    local file = filesystemOpenFunc(path, mode)

    path = getUniqeKey(path)
    openFiles[path] = file

    local fileCloseFunc = file.close
    ---@diagnostic disable-next-line
    function file:close()
        fileCloseFunc(self)
        openFiles[path] = nil
    end

    return file
end

return File, openFiles
