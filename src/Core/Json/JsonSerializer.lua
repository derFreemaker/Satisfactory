local Json = require("Core.Json.Json")

---@class Core.Json.Serializer : object
---@field private m_typeInfos table<string, Freemaker.ClassSystem.Type>
---@overload fun(typeInfos: Freemaker.ClassSystem.Type[]?) : Core.Json.Serializer
local JsonSerializer = {}
---@type Core.Json.Serializer
JsonSerializer.Static__Serializer = {} --[[@as unknown]]

---@private
---@param typeInfos Freemaker.ClassSystem.Type[]?
function JsonSerializer:__init(typeInfos)
    self.m_typeInfos = {}

    for _, typeInfo in ipairs(typeInfos or {}) do
        self.m_typeInfos[typeInfo.Name] = typeInfo
    end
end

function JsonSerializer:AddTypesFromStatic()
    for name, typeInfo in pairs(self.Static__Serializer.m_typeInfos) do
        if not Utils.Table.ContainsKey(self.m_typeInfos, name) then
            self.m_typeInfos[name] = typeInfo
        end
    end
end

---@param typeInfo Freemaker.ClassSystem.Type
---@return Core.Json.Serializer
function JsonSerializer:AddTypeInfo(typeInfo)
    if not Utils.Class.HasBase(typeInfo, "Core.Json.Serializable") then
        error("class:" .. typeInfo.Name .. " has not Core.Json.ISerializable as interface", 2)
    end
    if not Utils.Table.ContainsKey(self.m_typeInfos, typeInfo.Name) then
        self.m_typeInfos[typeInfo.Name] = typeInfo
    end
    return self
end

---@param typeInfos Freemaker.ClassSystem.Type[]
---@return Core.Json.Serializer
function JsonSerializer:AddTypeInfos(typeInfos)
    for _, typeInfo in ipairs(typeInfos) do
        self:AddTypeInfo(typeInfo)
    end
    return self
end

---@param class object
---@return Core.Json.Serializer
function JsonSerializer:AddClass(class)
    local typeInfo = typeof(class)
    if not typeInfo then
        return self
    end
    return self:AddTypeInfo(typeInfo)
end

---@param classes object[]
---@return Core.Json.Serializer
function JsonSerializer:AddClasses(classes)
    for _, class in ipairs(classes) do
        self:AddClass(class)
    end
    return self
end

---@private
---@param class Core.Json.ISerializable
---@return table data
function JsonSerializer:serializeClass(class)
    local typeInfo = typeof(class)
    if not typeInfo then
        error("unable to get type from class")
    end

    local data = { __Type = typeInfo.Name, __Data = { class:Serialize() } }

    local max = 0
    for key, value in next, data.__Data, nil do
        if key > max then
            max = key
        end
    end

    for i = 1, max, 1 do
        if data.__Data[i] == nil then
            data.__Data[i] = "%nil%"
        end
    end

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

    if Utils.Class.HasBase(obj, "Core.Json.ISerializable") then
        ---@cast obj Core.Json.ISerializable
        return self:serializeClass(obj)
    end

    for key, value in next, obj, nil do
        if type(value) == "table" then
            rawset(obj, key, self:serializeInternal(value))
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

    local typeInfo = self.m_typeInfos[t.__Type]
    if not typeInfo then
        error("unable to find typeInfo for class: " .. t.__Type)
    end

    local classBlueprint = typeInfo.Blueprint --[[@as Core.Json.ISerializable]]

    if type(data) == "table" then
        for key, value in next, data, nil do
            if value == "%nil%" then
                data[key] = nil
            end

            if type(value) == "table" then
                data[key] = self:deserializeInternal(value)
            end
        end
    end

    return classBlueprint:Static__Deserialize(table.unpack(data))
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

---@param str string
---@param outObj Out<any>
---@return boolean couldDeserialize
function JsonSerializer:TryDeserialize(str, outObj)
    local success, _, results = Utils.Function.InvokeProtected(self.Deserialize, self, str)
    outObj.Value = results[1]

    return success
end

class("Core.Json.Serializer", JsonSerializer)

JsonSerializer.Static__Serializer = JsonSerializer()
JsonSerializer.Static__Serializer:AddClass(require("Core.Common.UUID"))

return JsonSerializer
