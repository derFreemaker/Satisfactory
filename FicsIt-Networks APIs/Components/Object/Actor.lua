---@meta


--- This is the base class of all things that can exist within the world by them self.
---@class FicsIt_Networks.Components.Actor : FicsIt_Networks.Components.Object
---@field location FicsIt_Networks.Components.Vector The location of the actor in the world.
---@field scale FicsIt_Networks.Components.Vector The scale of the actor in the world.
---@field rotation FicsIt_Networks.Components.Rotator The rotation of the actor in the world.
local Actor = {}


--- Returns a list of power connectors this actor might have.
---@return FicsIt_Networks.Components.PowerConnection[] connectors The power connectors this actor has.
function Actor:getPowerConnectors() end