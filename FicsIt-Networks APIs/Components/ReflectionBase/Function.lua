---@meta

--- Bits and their meaning (least significant bit first)
---@alias  FicsIt_Networks.Components.Function.Flags
---|0 Is this function has a variable amount of input parameters.
---|1 Can this function get called in syncrounus runtime.
---|2 Can this function can get called in parallel runtime.
---|3 Can this function get called in asynchronus runtime.
---|4 Is this function a member function.
---|5 The function is a class function.
---|6 The function is a static function.
---|7 The function has a variable amount of return values.

--- A reflection object representing a function.
---@class FicsIt_Networks.Components.Function : FicsIt_Networks.Components.ReflectionBase
---@field flags FicsIt_Networks.Components.Function.Flags The function bit flag register defining some behavior of it.
local Function = {}

--- Returns all the parameters of this function.
---@return FicsIt_Networks.Components.Property[] parameters The parameters of this functions.
function Function:getParameters()
end
