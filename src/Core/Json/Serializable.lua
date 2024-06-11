---@alias Core.Json.Serializable.Types
---| string
---| number
---| boolean
---| table
---| Core.Json.Serializable

---@class Core.Json.Serializable
local Serializable = {}
---@return any ...
function Serializable:Serialize()
end

Serializable.Serialize = Utils.Class.IsInterface

---@param ... any
---@return any obj
function Serializable:Static__Deserialize(...)
    return self(...)
end

return interface("Core.Json.Serializable", Serializable)
