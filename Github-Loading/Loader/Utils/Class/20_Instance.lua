local LoadedLoaderFiles = ({ ... })[1]
---@type Utils.Table
local Table = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Table'][1]

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

    typeInfo.Instances[instance] = true
    InstanceHandler.Add(typeInfo.Base, instance)
end

function InstanceHandler.Remove(typeInfo, instance)
    if not typeInfo then
        return
    end

    typeInfo.Instances[instance] = nil
    InstanceHandler.Remove(typeInfo.Base, instance)
end

function InstanceHandler.UpdateMetaMethod(typeInfo, name, func)
    typeInfo.MetaMethods[name] = func

    for instance in pairs(typeInfo.Instances) do
        local instanceMetatable = getmetatable(instance)

        if not Table.ContainsKey(instanceMetatable, name) then
            rawset(instanceMetatable, name, func)
        end
    end
end

---@param typeInfo Utils.Class.Type
---@param key any
---@param value any
function InstanceHandler.UpdateMember(typeInfo, key, value)
    typeInfo.Members[key] = value

    for instance in pairs(typeInfo.Instances) do
        if not Table.ContainsKey(instance, key) then
            rawset(instance, key, value)
        end
    end
end

return InstanceHandler
