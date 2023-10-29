-- local LoadedLoaderFiles = ({ ... })[1]

---@class Utils.Class.Instance : table

---@class Utils.Class.InstanceHandler
local InstanceHandler = {}

---@param typeInfo Utils.Class.Type
function InstanceHandler.Initialize(typeInfo)
    typeInfo.Instances = setmetatable({}, { __mode = 'v' })
end

---@param typeInfo Utils.Class.Type
---@param instance Utils.Class.Instance
function InstanceHandler.Add(typeInfo, instance)
    if not typeInfo then
        return
    end

    table.insert(typeInfo.Instances, instance)
    InstanceHandler.Add(typeInfo.Base, instance)
end

return InstanceHandler
