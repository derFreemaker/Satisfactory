---@meta

--- This is the base class of all things that can exist within the world by them self.
---@class Satisfactory.Components.Actor : Satisfactory.Components.Object
local Actor = {}

--- The location of the actor in the world.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type Satisfactory.Components.Vector
Actor.location = nil

--- The scale of the actor in the world.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type Satisfactory.Components.Vector
Actor.scale = nil

--- The rotation of the actor in the world.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type Satisfactory.Components.Rotator
Actor.rotation = nil

--- Returns a list of power connectors this actor might have.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@return Satisfactory.Components.PowerConnection[] connectors The power connectors this actor has.
function Actor:getPowerConnectors()
end

--- Returns a list of factory connectors this actor might have.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@return Satisfactory.Components.FactoryConnection[] connectors The factory connectors this actor has.
function Actor:getFactoryConnectors()
end

--- Returns a list of pipe (fluid & hyper) connectors this actor might have.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@return Satisfactory.Components.PipeConnectionBase[] connectors The pipe connectors this actor has.
function Actor:getPipeConnectors()
end

--- Returns a list of inventories this actor might have.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@return Satisfactory.Components.Inventory[] inventories The inventories this actor has.
function Actor:getInventories()
end

--- Returns the name of network connectors this actor might have.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@return Satisfactory.Components.ActorComponent[] connectors The factory connectors this actor has.
function Actor:getNetworkConnectors()
end

--- Returns the components that make-up this actor.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@param componentType Satisfactory.Components.ActorComponent The class will be used as filter.
---@return Satisfactory.Components.ActorComponent components The components of this actor.
function Actor:getComponents(componentType)
end
