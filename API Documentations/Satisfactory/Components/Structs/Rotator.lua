---@meta

--- Contains rotation information about the object in 3D spaces using 3 rotation axis in a gimble.
---@class Satisfactory.Components.Rotator : FIN.Struct
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

--- The addition (+) operator for this struct.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param factor number The other rotator that should be added to this rotator
---@return Satisfactory.Components.Rotator result The resulting rotator of the vector addition
function Rotator:FIN_Operator_Add(factor)
end

--- The subtraction (-) operator for this struct.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param factor number The other rotator that should be subtracted from this rotator
---@return Satisfactory.Components.Rotator result The resulting rotator of the vector subtraction
function Rotator:FIN_Operator_Sub(factor)
end
