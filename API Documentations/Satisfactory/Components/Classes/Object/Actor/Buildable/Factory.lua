---@meta

--- The base class of most machines you can build.
---@class Satisfactory.Components.Factory : Satisfactory.Components.Buildable
local Factory = {}

--- The current production progress of the current production cycle.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
Factory.progress = nil

--- The power consumption when producing.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
Factory.powerConsumProducing = nil

--- The productivity of this factory.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
Factory.productivity = nil

--- The time that passes till one production cycle is finished.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
Factory.cycleTime = nil

--- The maximum potential this factory can be set to.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
Factory.maxPotential = nil

--- The minimum potential this factory needs to be set to.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
Factory.minPotential = nil

--- True if the factory is in standby.
--- ### Flags:
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@type boolean
Factory.standby = nil

--- The potential this factory is currently set to. (the overclock value) 0 = 0%, 1 = 100%
--- ### Flags:
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@type float
Factory.potential = nil
