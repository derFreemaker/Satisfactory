---@meta

--- Contains rotation information about the object in 3D spaces using 3 rotation axis in a gimble.
---@class FicsIt_Networks.Components.Rotator
local Rotator = {}

--- The pitch component.
--- ### Flags:
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@type float
Rotator.pitch = nil

--- The yaw component.
--- ### Flags:
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@type float
Rotator.yaw = nil

--- The roll component.
--- ### Flags:
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@type float
Rotator.roll = nil
