---@class FactoryControl.Client.Entities.Entity : object
---@field Id Core.UUID
---@field protected _Client FactoryControl.Client.Client
local Entity = {}

---@private
---@param id Core.UUID
---@param client FactoryControl.Client.Client
function Entity:__init(id, client)
    self.Id = id
    self._Client = client
end

return Utils.Class.CreateClass(Entity, "FactoryControl.Client.Entities.Entity")
