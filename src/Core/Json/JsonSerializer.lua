local Json = require("Core.Json.Json")

---@class Core.Json.Serializer
---@field private _TypeInfos Utils.Class.Type[]
---@overload fun(typeInfos: Utils.Class.Type[]?) : Core.Json.Serializer
local Serializer = {}

---@param typeInfos Utils.Class.Type[]?
function Serializer:__init(typeInfos)
    self._TypeInfos = typeInfos or {}
end

---@param typeInfo Utils.Class.Type
---@return Core.Json.Serializer
function Serializer:AddTypeInfo(typeInfo)
    table.insert(self._TypeInfos, typeInfo)
    return self
end

---@param typeInfos Utils.Class.Type[]
---@return Core.Json.Serializer
function Serializer:AddTypeInfos(typeInfos)
    for _, typeInfo in ipairs(typeInfos) do
        table.insert(self._TypeInfos, typeInfo)
    end
    return self
end

---@private
---@param class object
---@return table data
function Serializer:serializeClass(class)
    local typeInfo = class:Static__GetType()
    if not Utils.Class.HasBaseClass("Core.Json.Serializable", typeInfo) then
        error("can not serialize class: " .. typeInfo.Name .. " use 'Core.Json.Serializable' as base class")
    end
    ---@cast class Core.Json.Serializable

    local data = { __Type = typeInfo.Name, __Data = class:Static__Serialize() }

    if type(data.__Data) == "table" then
        for key, value in next, data.__Data, nil do
            data.__Data[key] = self:serializeInternal(value)
        end
    end

    return data
end

---@private
---@param obj any
---@return table data
function Serializer:serializeInternal(obj)
    local objType = type(obj)
    if objType ~= "table" then
        if not Utils.Table.ContainsKey(Json.type_func_map, objType) then
            error("can not serialize: " .. objType .. " value: " .. tostring(obj))
            return {}
        end

        return obj
    end

    if Utils.Class.IsClass(obj) then
        ---@cast obj object
        return self:serializeClass(obj)
    end

    for key, value in next, obj, nil do
        local valueType = type(value)
        if Utils.Class.IsClass(value) then
            ---@cast value object
            obj[key] = self:serializeClass(value)
        elseif not Utils.Table.ContainsKey(Json.type_func_map, valueType) then
            error("can not serialize: " .. valueType .. " value: " .. tostring(value))
            return {}
        end
    end
    return obj
end

---@param obj table
---@return string str
function Serializer:Serialize(obj)
    return Json.encode(self:serializeInternal(obj))
end

---@private
---@param t table
---@return boolean isDeserializedClass
local function isDeserializedClass(t)
    if not t.__Type then
        return false
    end

    return true
end

---@private
---@param t table
---@return object class
function Serializer:deserializeClass(t)
    local data = t.__Data
    ---@type Core.Json.Serializable
    local classTemplate

    for _, typeInfo in ipairs(self._TypeInfos) do
        if typeInfo.Name == t.__Type then
            classTemplate = Utils.Class.CreateClassTemplate(typeInfo) --[[@as Core.Json.Serializable]]
            break
        end
    end

    if type(data) == "table" then
        for key, value in next, data, nil do
            if type(value) == "table" and isDeserializedClass(value) then
                data[key] = self:deserializeClass(value)
            end
        end
    end


    return classTemplate.Static__Deserialize(data)
end

---@private
---@param t table
---@return any obj
function Serializer:deserializeInternal(t)
    if isDeserializedClass(t) then
        return self:deserializeClass(t)
    end

    for key, value in next, t, nil do
        if isDeserializedClass(value) then
            t[key] = self:deserializeClass(value)
        end
    end

    return t
end

---@param str string
---@return any obj
function Serializer:Deserialize(str)
    local obj = Json.decode(str)

    if type(obj) == "table" then
        return self:deserializeInternal(obj)
    end

    return obj
end

return Utils.Class.CreateClass(Serializer, "Core.Json.JsonSerializer")
