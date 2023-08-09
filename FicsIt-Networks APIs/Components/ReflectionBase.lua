---@diagnostic disable

--- The base class for all things of the reflection system.
---@class FicsIt_Networks.Components.ReflectionBase : FicsIt_Networks.Components.Object
---@field name string The internal name.
---@field displayName string The display name used in UI which might be localized.
---@field description string The description of this base.
local ReflectionBase = {}