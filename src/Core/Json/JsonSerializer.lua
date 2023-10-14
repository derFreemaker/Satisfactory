local Json = require("Core.Json.Json")

---@class Core.Json.Serializer : object
local Serializer = {}

---@private
---@param class object
---@return table data
function Serializer:serializeClass(class)
    local typeInfo = class:GetType()
    if not Utils.Class.HasBaseClass("Core.Json.Serializable", typeInfo) then
        error("can not serialize class: " .. typeInfo.Name .. " use 'Core.Json.Serializable' as base class")
    end
    ---@cast class Core.Json.Serializable

    local data = { __Type = typeInfo.Name, __Data = class:Static__Serialize() }

    if type(data) == "table" then
        for key, value in next, data.__Data, nil do
            data.__Data[key] = self:serializeInternal(value)
        end
    end

    return data
end

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
    local classTemplate = require(t.__Type)

    for key, value in next, data, nil do
        if type(value) == "table" and isDeserializedClass(value) then
            data[key] = self:deserializeClass(value)
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
        if Utils.Class.IsClass(value) then
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

return Utils.Class.CreateClass(Serializer, "Core.Json.Serializer")
