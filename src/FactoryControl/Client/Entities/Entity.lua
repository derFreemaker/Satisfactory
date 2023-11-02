---@class FactoryControl.Client.Entities.Entity : object
---@field Id Core.UUID
---@field protected m_client FactoryControl.Client
---@overload fun(id: Core.UUID, client: FactoryControl.Client) : FactoryControl.Client.Entities.Entity
local Entity = {}

---@alias FactoryControl.Client.Entities.Entity.Constructor fun(id: Core.UUID, client: FactoryControl.Client)

---@private
---@param id Core.UUID
---@param client FactoryControl.Client
function Entity:__init(id, client)
    self.Id = id
    self.m_client = client
end

return Utils.Class.CreateClass(Entity, "FactoryControl.Client.Entities.Entity")
