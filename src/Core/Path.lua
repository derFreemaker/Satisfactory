---@class Core.Path
---@field private path string
---@overload fun(path: string?) : Core.Path
local Path = {}

---@param path string
---@boolean
function Path.Static__IsNode(path)
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

---@private
---@param path string?
function Path:__init(path)
    if not path or path == "" then
        self.path = ""
        return
    end
    self.path = path:gsub("\\", "/")
end

---@return string
function Path:GetPath()
    return self.path
end

---@param node string
---@return Core.Path
function Path:Append(node)
    local pos = self.path:len() - self.path:reverse():find("/")
    if node == "." or node == ".." or Path.Static__IsNode(node) then
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

---@return Core.Path
function Path:GetParentFolderPath()
    local pos = self.path:reverse():find("/")
    if not pos then
        return Path()
    end
    local path = self.path:sub(0, self.path:len() - pos)
    return Path(path)
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

---@param other Core.Path
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

---@return Core.Path
function Path:Normalize()
    local newPath = Path()
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
        elseif Path.Static__IsNode(node) then
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

---@return Core.Path
function Path:Absolute()
    if self:IsAbsolute() then
        return Path(self:Normalize().path)
    end
    return Path("/" .. self:Normalize().path)
end

---@return Core.Path
function Path:Relative()
    if self:IsAbsolute() then
        return Path(self:Normalize().path:sub(1))
    end
    return self:Normalize()
end

---@param pathExtension string
---@return Core.Path
function Path:Extend(pathExtension)
    local path = self.path
    local pos = path:len() - path:reverse():find("/")
    if pathExtension == "." or pathExtension == ".." or Path.Static__IsNode(pathExtension) then
        if pos ~= path:len() - 1 then
            path = path .. "/"
        end
        path = path .. pathExtension
    elseif pathExtension == "/" then
        path = path .. pathExtension
    end
    return Path(path)
end

function Path:Copy()
    return Path(self.path)
end

return Utils.Class.CreateClass(Path, "Core.Path")