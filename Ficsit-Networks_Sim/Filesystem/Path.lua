---@alias Ficsit_Networks_Sim.Filesystem.Path.Change integer
---|0 Normalize the path.
---|1 Normalizes and converts the path to an absolute path.
---|2 Normalizes and converts the path to an relative path.
---|3 Returns the whole file/folder name.
---|4 Returns the stem of the filename.
---|5 Returns the file-extension of the filename.

---@class Ficsit_Networks_Sim.Filesystem.Path
---@field private sepperatorPattern string
---@field private path string
local Path = {
    sepperatorPattern = "[\\\\\\/\\|]"
}
Path.__index = Path

---@param path string
---@boolean
function Path.IsNode(path)
    if path:find("/") then
        return false
    end
    if path:find("\\") then
        return false
    end
    if path:find("|") then
        return false
    end
    return true
end

---@param path string | nil
---@return Ficsit_Networks_Sim.Filesystem.Path
function Path.new(path)
    local newPath = setmetatable({ path = "" }, Path)
    if not path or path == "" then
        return newPath
    end
    newPath.path = path:gsub("\\", "/")
    return newPath
end

---@return string
function Path:GetPath()
    return self.path
end

---@param node string
---@return Ficsit_Networks_Sim.Filesystem.Path
function Path:Append(node)
    local pos = self.path:len() - self.path:reverse():find("/")
    if node == "." or node == ".." or Path.IsNode(node) then
        if pos ~= self.path:len() - 1 then
            self.path = self.path .. "/"
        end
        self.path = self.path .. node
    elseif node == "/" then
        self.path = self.path .. node
    end
    return self
end

---@return string
function Path:GetRoot()
    local str = self:Relative().path
    local slash = str:find("/")
    return str:sub(0, slash)
end

---@return boolean
function Path:IsSingle()
    local pos = self.path:find("/", 1)
    return (pos == 0 and self.path:len() > 0 and self.path ~= "/")
end

---@return boolean
function Path:IsAbsolute()
    return self.path:sub(0, 1) == "/"
end

---@return boolean
function Path:IsEmpty()
    return (self.path:len() == 1 and self:IsAbsolute()) or self.path:len() == 0
end

---@return boolean
function Path:IsRoot()
    return self.path == "/"
end

---@return boolean
function Path:IsDir()
    local reversedPath = self.path:reverse()
    return reversedPath:sub(0, 1) == "/"
end

---@param other Ficsit_Networks_Sim.Filesystem.Path
---@return boolean
function Path:StartsWith(other)
    if other:IsAbsolute() then
        other = other:Absolute()
    else
        other = other:Relative()
    end
    return self.path:sub(0, other.path:len()) == other.path
end

---@return string
function Path:GetFileName()
    local slash = (self.path:reverse():find("/") or 0) - 2
    if slash == nil or slash == -2 then
        return self.path
    end
    return self.path:sub(self.path:len() - slash)
end

---@return string
function Path:GetFileExtension()
    local name = self:GetFileName()
    local pos = (name:reverse():find("%.") or 0) - 1
    if pos == nil or pos == -1 then
        return ""
    end
    return name:sub(name:len() - pos)
end

---@return string
function Path:GetFileStem()
    local name = self:GetFileName()
    local pos = (name:reverse():find("%.") or 0)
    local lenght = name:len()
    if pos == lenght then
        return name
    end
    return name:sub(0, lenght - pos)
end

---@return Ficsit_Networks_Sim.Filesystem.Path
function Path:Normalize()
    local newPath = Path.new()
    if self:IsAbsolute() then
        newPath.path = "/"
    end
    local posStart = 0
    local posEnd = self.path:find("/", posStart)
    while true do
        local node = self.path:sub(posStart, posEnd - 1)
        posStart = posEnd + 1
        if node == "." then
        elseif node == ".." then
            local pos = newPath.path:len() - newPath.path:reverse():find("/")
            if pos == nil then
                newPath.path = ""
            else
                newPath.path = newPath.path:sub(pos)
            end
            if newPath.path:len() < 1 and self:IsAbsolute() then
                newPath.path = "/"
            end
        elseif Path.IsNode(node) then
            if newPath.path:len() > 0 and newPath.path:reverse():find("/") ~= 1 then
                newPath.path = newPath.path .. "/"
            end
            newPath.path = newPath.path .. node
        end

        if posEnd == self.path:len() + 1 then
            break
        end

        local newPosEnd = self.path:find("/", posStart)
        if newPosEnd == nil then
            posStart = posEnd + 1
            newPosEnd = self.path:len() + 1
        end
        posEnd = newPosEnd
    end
    return newPath
end

---@return Ficsit_Networks_Sim.Filesystem.Path
function Path:Absolute()
    if self:IsAbsolute() then
        return Path.new(self:Normalize().path)
    end
    return Path.new("/".. self:Normalize().path)
end

---@return Ficsit_Networks_Sim.Filesystem.Path
function Path:Relative()
    if self:IsAbsolute() then
        return Path.new(self:Normalize().path:sub(1))
    end
    return self:Normalize()
end

---@return Ficsit_Networks_Sim.Filesystem.Path
function Path:Extend(node)
    local path = self.path
    local pos = path:len() - path:reverse():find("/")
    if node == "." or node == ".." or Path.IsNode(node) then
        if pos ~= path:len() - 1 then
            path = path .. "/"
        end
        path = path .. node
    elseif node == "/" then
        path = path .. node
    end
    return Path.new(path)
end

function Path:Copy()
    return Path.new(self.path)
end

return Path