---@class FactoryControl.Client.Entities.Controller.Feature.Chart.Update : Core.Json.Serializable
---@field Id Core.UUID
---@field Data table<number, any>
---@overload fun(id: Core.UUID, data: table<number, any>) : FactoryControl.Client.Entities.Controller.Feature.Chart.Update
local Update = {}

---@private
---@param id Core.UUID
---@param data table<number, any>
function Update:__init(id, data)
    self.Id = id
    self.Data = data
end

---@return Core.UUID id, table<number, any> data
function Update:Serialize()
    return self.Id, self.Data
end

return Utils.Class.CreateClass(Update, "FactoryControl.Client.Entities.Controller.Feature.Chart.Update",
    require("Core.Json.Serializable"))
