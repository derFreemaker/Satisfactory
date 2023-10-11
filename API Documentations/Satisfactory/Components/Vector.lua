---@meta

--- Contains three cordinates (X, Y, Z) to describe a postition or movement vector in 3D Space
---@class Satisfactory.Components.Vector
local Vector = {}

--- The X coordinate component.
--- ### Flags:
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@type float
Vector.X = nil

--- The Y coordinate component.
--- ### Flags:
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@type float
Vector.Y = nil

--- The Z coordinate component.
--- ### Flags:
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@type float
Vector.Z = nil
