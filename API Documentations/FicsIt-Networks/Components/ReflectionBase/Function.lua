---@meta

--- Bits and their meaning (least significant bit first)
---@alias  FIN.Components.Function.Flags
---|0 Is this function has a variable amount of input parameters.
---|1 Can this function get called in syncrounus runtime.
---|2 Can this function can get called in parallel runtime.
---|3 Can this function get called in asynchronus runtime.
---|4 Is this function a member function.
---|5 The function is a class function.
---|6 The function is a static function.
---|7 The function has a variable amount of return values.

--- A reflection object representing a function.
---@class FIN.Components.Function : FIN.Components.ReflectionBase
local Function = {}

--- The function bit flag register defining some behavior of it.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type FIN.Components.Function.Flags
Function.flags = nil

--- Returns all the parameters of this function.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@return FIN.Components.Property[] parameters The parameters of this functions.
function Function:getParameters()
end
