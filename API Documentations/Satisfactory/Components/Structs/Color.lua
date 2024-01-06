---@meta

---@class Satisfactory.Components.Color : FIN.Struct
local Color = {}

--- The red portion of the color.
--- ### Flags:
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@type float
Color.r = nil

--- The green protion of the color.
--- ### Flags:
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@type float
Color.g = nil

--- The blue protion of the color.
--- ### Flags:
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@type float
Color.b = nil

--- The alpha (opacity) portion of the color.
--- ### Flags:
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@type float
Color.a = nil

--- The addition (+) operator for this struct.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param other Satisfactory.Components.Color The other color that should be added to this color
---@return Satisfactory.Components.Color result The resulting color of the color addition
function Color:FIN_Operator_Add(other)
end

--- The Negation operator for this struct. Does NOT make the color negative. Calculates 1 - this.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satisfactory.Components.Color result The resulting color of the color addition
function Color:FIN_Operator_Neg_1()
end

--- The subtraction (-) operator for this struct.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param other Satisfactory.Components.Color The other color that should be subtracted from this color.
---@return Satisfactory.Components.Color result The resulting color of the color subtraction
function Color:FIN_Operator_Sub(other)
end

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param factor number The factor with which this color should be scaled with.
---@return Satisfactory.Components.Color result The resulting scaled color.
function Color:FIN_Operator_Mul_1(factor)
end

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param factor number The factor with which this color should be scaled inversly with.
---@return Satisfactory.Components.Color result The resulting inverse scaled color.
function Color:FIN_Operator_Div_1(factor)
end
