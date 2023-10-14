---@class Core.Json.Serializable : object
local Serializable = {}

---@return table data
function Serializable:Static__Serialize()
    error("function not overriden")
end

---@param data table
---@return table obj
function Serializable.Static__Deserialize(data)
    error("function not overriden")
end

return Utils.Class.CreateClass(Serializable, "Core.Json.Serializable")
