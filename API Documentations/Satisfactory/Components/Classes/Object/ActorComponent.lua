---@meta

--- A component/part of an actor in the world.
---@class Satisfactory.Components.ActorComponent : Satisfactory.Components.Object
local ActorComponent = {}

--- The parent actor of wich this component is part of
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type Satisfactory.Components.Actor
ActorComponent.owner = nil
