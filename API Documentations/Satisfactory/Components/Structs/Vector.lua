---@meta

--- Contains three coordinates (X, Y, Z) to describe a position or movement vector in 3D Space
---@class Satisfactory.Components.Vector : FIN.Struct
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

--- The addition (+) operator for this struct.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param other Satisfactory.Components.Vector The other vector that should be added to this vector
---@return Satisfactory.Components.Vector result The resulting vector of the vector addition
function Vector:FIN_Operator_Add(other)
end

--- The subtraction (-) operator for this struct.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param other Satisfactory.Components.Vector The other vector that should be subtracted from this vector
---@return Satisfactory.Components.Vector result The resulting vector of the vector subtraction
function Vector:FIN_Operator_Sub(other)
end

--- The Negation operator for this struct.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satisfactory.Components.Vector result The resulting vector of the vector negation
function Vector:FIN_Operator_Neg()
end

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param other Satisfactory.Components.Vector The other vector to calculate the scalar product with.
---@return float result The resulting scalar product.
function Vector:FIN_Operator_Mul(other)
end

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param other Satisfactory.Components.Vector The factor with which this vector should be scaled with.
---@return Satisfactory.Components.Vector result The resulting scaled vector.
function Vector:FIN_Operator_Mul_1(other)
end
