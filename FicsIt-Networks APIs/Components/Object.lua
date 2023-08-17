---@meta

--- The base class of ervery object
---@class FicsIt_Networks.Components.Object : FicsIt_Networks.Component
---@field hash integer A Hash of this object. This is a value that nearly uniquely identifies this object.
---@field internalName string The unreal engine internal name of this object.
---@field internalPath string The unreal engine internal path name of this object.
local Object = {}


--- Returns the hash of this class. This is a value that nearly uniquely identifies this object.
---@return integer Hash
function Object:getHash() end


--- Returns the type (aka class) of this class instance
---@return FicsIt_Networks.Components.Class type The type of this class instance
function Object:getType() end