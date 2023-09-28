---@meta

--- # not a property only for documentation purposes
--- A reflection object representing a signal.
---@class FicsIt_Networks.Components.Signal : FicsIt_Networks.Components.ReflectionBase
---@field isVarArgs boolean True if this signal has a variable amount of arguments.
local Signal = {}

--- Returns all the parameters of this signal.
---@return FicsIt_Networks.Components.Property[] parameters The parameters this signal.
function Signal:getParameters()
end
