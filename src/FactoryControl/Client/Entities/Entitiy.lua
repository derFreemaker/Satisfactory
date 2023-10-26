---@class FactoryControl.Client.Entities.Entity : object
---@field Id Core.UUID
---@field protected m_client FactoryControl.Client
local Entity = {}

---@private
---@param id Core.UUID
---@param client FactoryControl.Client
function Entity:__init(id, client)
    self.Id = id
    self.m_client = client
end

return Utils.Class.CreateClass(Entity, "FactoryControl.Client.Entities.Entity")
