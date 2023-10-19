---@class Core.Json.Serializable : object
local Serializable = {}

---@return any ...
function Serializable:Serialize()
    return tostring(self)
end

---@param ... any
---@return any obj
function Serializable:Static__Deserialize(...)
    return self(...)
end

return Utils.Class.CreateClass(Serializable, "Core.Json.Serializable")
