---@alias Ficsit_Networks_Sim.Filesystem.FilesystemEntity.Type
---|"main" only main can be
---|"tmpfs" this is the only valid type you can add

---@class Ficsit_Networks_Sim.Filesystem.FilesystemEntity
---@field Type Ficsit_Networks_Sim.Filesystem.FilesystemEntity.Type
---@field Name string
---@field Path string
local FilesystemEntity = {}
FilesystemEntity.__index = FilesystemEntity

---@param type Ficsit_Networks_Sim.Filesystem.FilesystemEntity.Type
---@param name string
---@return Ficsit_Networks_Sim.Filesystem.FilesystemEntity
function FilesystemEntity.new(type, name)
    local path = name
    if path:find("/") ~= 1 then
        path = "/" .. path
    end
    return setmetatable({
        Type = type,
        Name = name,
        Path = path
    }, FilesystemEntity)
end

return FilesystemEntity