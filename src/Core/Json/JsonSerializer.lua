local Json = require("Core.Json.Json")

---@class Core.Json.Serializer
---@field private _TypeInfos Dictionary<string, Utils.Class.Type>
---@overload fun(typeInfos: Utils.Class.Type[]?) : Core.Json.Serializer
local JsonSerializer = {}

---@type Core.Json.Serializer
JsonSerializer.Static__Serializer = Utils.Class.Placeholder

---@private
---@param typeInfos Utils.Class.Type[]?
function JsonSerializer:__init(typeInfos)
    self._TypeInfos = {}

    for _, typeInfo in ipairs(typeInfos or {}) do
        self._TypeInfos[typeInfo.Name] = typeInfo
    end
end

function JsonSerializer:AddDefaultTypeInfos()
    self:AddTypeInfos({
        require("Core.UUID"):Static__GetType()
    })
end

---@param typeInfo Utils.Class.Type
---@return Core.Json.Serializer
function JsonSerializer:AddTypeInfo(typeInfo)
    if not Utils.Class.HasBaseClass("Core.Json.Serializable", typeInfo) then
        error("class type has not Core.Json.Serializable as base class", 2)
    end
    if not Utils.Table.ContainsKey(self._TypeInfos, typeInfo.Name) then
        self._TypeInfos[typeInfo.Name] = typeInfo
    end
    return self
end

---@param typeInfos Utils.Class.Type[]
---@return Core.Json.Serializer
function JsonSerializer:AddTypeInfos(typeInfos)
    for _, typeInfo in ipairs(typeInfos) do
        self:AddTypeInfo(typeInfo)
    end
    return self
end

---@private
---@param class object
---@return table data
function JsonSerializer:serializeClass(class)
    local typeInfo = class:Static__GetType()
    if not Utils.Class.HasBaseClass("Core.Json.Serializable", typeInfo) then
        error("can not serialize class: " .. typeInfo.Name .. " use 'Core.Json.Serializable' as base class")
    end
    ---@cast class Core.Json.Serializable

    local data = { __Type = typeInfo.Name, __Data = { class:Serialize() } }

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
function JsonSerializer:serializeInternal(obj)
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
        if type(value) == "table" then
            obj[key] = self:serializeInternal(value)
        end
    end

    return obj
end

---@param obj any
---@return string str
function JsonSerializer:Serialize(obj)
    return Json.encode(self:serializeInternal(obj))
end

---@private
---@param t table
---@return boolean isDeserializedClass
local function isDeserializedClass(t)
    if not t.__Type then
        return false
    end

    if not t.__Data then
        return false
    end

    return true
end

---@private
---@param t table
---@return object class
function JsonSerializer:deserializeClass(t)
    local data = t.__Data

    local typeInfo = self._TypeInfos[t.__Type]
    if not typeInfo then
        error("unable to find typeInfo for class: " .. t.__Type)
    end

    ---@type Core.Json.Serializable
    local classTemplate = typeInfo.Template

    if type(data) == "table" then
        for key, value in next, data, nil do
            if type(value) == "table" then
                data[key] = self:deserializeInternal(value)
            end
        end
    end

    return classTemplate.Static__Deserialize(table.unpack(data))
end

---@private
---@param t table
---@return any obj
function JsonSerializer:deserializeInternal(t)
    if isDeserializedClass(t) then
        return self:deserializeClass(t)
    end

    for key, value in next, t, nil do
        if type(value) == "table" then
            t[key] = self:deserializeInternal(value)
        end
    end

    return t
end

---@param str string
---@return any obj
function JsonSerializer:Deserialize(str)
    local obj = Json.decode(str)

    if type(obj) == "table" then
        return self:deserializeInternal(obj)
    end

    return obj
end

Utils.Class.CreateClass(JsonSerializer, "Core.Json.JsonSerializer")

JsonSerializer.Static__Serializer = JsonSerializer()
JsonSerializer.Static__Serializer:AddDefaultTypeInfos()

return JsonSerializer
