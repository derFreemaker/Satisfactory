local Utils = require("Utils")

---@class BundlePart
---@field UUID string
---@field Path string
---@field Name string
---@field FullName string
---@field IsFolder boolean
---@field File File | nil
---@field Folder Folder | nil
---@field Childs BundlePart[] | nil
---@field Parent BundlePart | nil
local BundlePart = {}
BundlePart.__index = BundlePart

---@param uuid string
---@param folder Folder
---@param parent BundlePart | nil
---@return BundlePart
function BundlePart.newFromFolder(uuid, folder, parent)
    parent = parent or nil
    folder:Scan()
    return setmetatable({
        UUID = uuid,
        Path = folder.Path,
        Name = folder.Name,
        FullName = folder.Name,
        IsFolder = true,
        File = nil,
        Folder = folder,
        Childs = {},
        Parent = parent
    }, BundlePart)
end

---@param uuid string
---@param file File
---@param parent BundlePart | nil
---@return BundlePart
function BundlePart.newFromFile(uuid, file, parent)
    return setmetatable({
        UUID = uuid,
        Path = file.Path,
        Name = file.Name,
        FullName = file.FullName,
        IsFolder = false,
        File = file,
        Folder = nil,
        Childs = nil,
        Parent = parent
    }, BundlePart)
end

function BundlePart:Build()
    if not self.IsFolder then return end
    for _, file in ipairs(self.Folder.Files) do
        if file.Extension == "lua" then
            local uuid = Utils.GenerateNewUUID()
            local bundlePart = BundlePart.newFromFile(uuid, file)
            table.insert(self.Childs, bundlePart)
        end
    end
    for _, folder in ipairs(self.Folder.Folders) do
        local uuid = Utils.GenerateNewUUID()
        local bundlePart = BundlePart.newFromFolder(uuid, folder)
        table.insert(self.Childs, bundlePart)
        bundlePart:Build()
    end
end

return BundlePart