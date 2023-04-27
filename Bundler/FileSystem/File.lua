---@class File
---@field Path string
---@field FullName string
---@field Name string
---@field Extension string
local File = {}
File.__index = File

---@param fullFileName string
---@return string, string
function File.SplitFileNameAndExtension(fullFileName)
    return fullFileName:match("(.+)%.(.+)$")
end

---@param path string
---@return File
function File.new(path)
    local fullName = path:gsub("\\", "/"):match(".+%/(.+)$")
    local name, ext = File.SplitFileNameAndExtension(fullName)
    return setmetatable({
        Path = path,
        FullName = fullName,
        Name = name,
        Extension = ext
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

return File