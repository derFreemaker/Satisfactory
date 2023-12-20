---@class OS.Installer.Tools
local Tools = {}

---@class OS.Installer.Tool.Tree
---@field m_fileFunc fun(path: string) : boolean
---@field m_folderFunc fun(path: string) : boolean
local Tree = {}

---@param fileFunc fun(path: string) : boolean
---@param folderFunc fun(path: string) : boolean
function Tree.new(fileFunc, folderFunc)
    local instance = {}
    instance.m_fileFunc = fileFunc
    instance.m_folderFunc = folderFunc
    return setmetatable(instance, { __index = Tree })
end

---@private
---@param parentPath string
---@param entry table | string
---@return boolean
function Tree:doEntry(parentPath, entry)
    if #entry == 1 then
        ---@cast entry string
        return self:doFile(parentPath, entry)
    else
        ---@cast entry table
        return self:doFolder(parentPath, entry)
    end
end

---@private
---@param parentPath string
---@param file string
---@return boolean
function Tree:doFile(parentPath, file)
    local path = filesystem.path(parentPath, file[1])
    return self.m_fileFunc(path)
end

---@param parentPath string
---@param folder table
---@return boolean
function Tree:doFolder(parentPath, folder)
    local path = filesystem.path(parentPath, folder[1])
    if not self.m_folderFunc(path) then
        return false
    end
    for index, child in pairs(folder) do
        if index ~= 1 then
            local success = self:doEntry(path, child)
            if not success then
                return false
            end
        end
    end
    return true
end

Tools.Tree = Tree

return Tools
