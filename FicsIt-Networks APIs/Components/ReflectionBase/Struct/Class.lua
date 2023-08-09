---@diagnostic disable


--- Object that contains all information about a type.
---@class FicsIt_Networks.Components.Class : FicsIt_Networks.Components.Struct
local Class = {}


--- Returns all the signals of this type.
---@return FicsIt_Networks.Components.Signal[] signals The signals this specific type implements (excluding signals from parent types).
function Class:getSignals() end


--- Returns all the signals of this and its parent types.
---@return FicsIt_Networks.Components.Signal[] signals The signals this type and all it parents implements.
function Class:getAllSignals() end