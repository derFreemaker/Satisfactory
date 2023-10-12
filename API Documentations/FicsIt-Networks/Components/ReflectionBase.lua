---@meta

--- The base class for all things of the reflection system.
---@class FIN.Components.ReflectionBase : Satisfactory.Components.Object
local ReflectionBase = {}

--- The internal name.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type string
ReflectionBase.name = nil

--- The display name used in UI which might be localized.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type string
ReflectionBase.displayName = nil

--- The description of this base.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type string
ReflectionBase.description = nil
