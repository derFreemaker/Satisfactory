---@alias Core.Json.Serializable.Types
---| string
---| number
---| boolean
---| table
---| Core.Json.Serializable

---@class Core.Json.Serializable : object
local Serializable = {}

---@return any ...
function Serializable:Serialize()
    local typeInfo = self:Static__GetType()
    error("Serialize function was not override for type " .. typeInfo.Name)
end

---@param ... any
---@return any obj
function Serializable:Static__Deserialize(...)
    return self(...)
end

return Utils.Class.CreateClass(Serializable, "Core.Json.Serializable")
