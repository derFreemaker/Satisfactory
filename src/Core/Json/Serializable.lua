---@class Core.Json.Serializable : object
local Serializable = {}

---@return any ...
function Serializable:Serialize()
    error("function is not overriden")
end

---@param ... any
---@return any obj
function Serializable.Static__Deserialize(...)
    error("function is not overriden")
end

return Utils.Class.CreateClass(Serializable, "Core.Json.Serializable")
