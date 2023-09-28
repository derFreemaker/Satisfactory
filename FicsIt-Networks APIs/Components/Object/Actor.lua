---@meta

--- This is the base class of all things that can exist within the world by them self.
---@class FicsIt_Networks.Components.Actor : FicsIt_Networks.Components.Object
---@field location FicsIt_Networks.Components.Vector The location of the actor in the world.
---@field scale FicsIt_Networks.Components.Vector The scale of the actor in the world.
---@field rotation FicsIt_Networks.Components.Rotator The rotation of the actor in the world.
local Actor = {}

--- Returns a list of power connectors this actor might have.
---@return FicsIt_Networks.Components.PowerConnection[] connectors The power connectors this actor has.
function Actor:getPowerConnectors()
end

--- Returns a list of factory connectors this actor might have.
---@return FicsIt_Networks.Components.FactoryConnection[] connectors The factory connectors this actor has.
function Actor:getFactoryConnectors()
end

--- Returns a list of pipe (fluid & hyper) connectors this actor might have.
---@return FicsIt_Networks.Components.PipeConnectionBase[] connectors The pipe connectors this actor has.
function Actor:getPipeConnectors()
end

--- Returns a list of inventories this actor might have.
---@return FicsIt_Networks.Components.Inventory[] inventories The inventories this actor has.
function Actor:getInventories()
end

--- Returns the name of network connectors this actor might have.
---@return FicsIt_Networks.Components.ActorComponent[] connectors The factory connectors this actor has.
function Actor:getNetworkConnectors()
end

---@deprecated
--- ### Experimental Only ###
--- Returns the components that make-up this actor.
---@param componentType FicsIt_Networks.Components.ActorComponent The class will be used as filter.
---@return FicsIt_Networks.Components.ActorComponent components The components of this actor.
function Actor:getComponents(componentType)
end

-- //TODO: finish documentation see Templates.lua
