---@meta

--- Reflection Object that holds information about structures.
---@class FicsIt_Networks.Components.Struct : FicsIt_Networks.Components.ReflectionBase
local Struct = {}

--- Returns the parent type of this type
---@return FicsIt_Networks.Components.Class parent The parent type of this type.
function Struct:getParent()
end

--- Returns all the properties of this type.
---@return FicsIt_Networks.Components.Property[] properties The properties this specific type implements (excluding properties from parent types).
function Struct:getProperties()
end

--- Returns all the properties of this and parent types.
---@return FicsIt_Networks.Components.Property[] properties The properties this type implements including properties from parent types.
function Struct:getAllProperties()
end

--- Returns all the functions of this type.
---@return FicsIt_Networks.Components.Function[] functions The functions this specific type implements (excluding functions from parent types).
function Struct:getFunctions()
end

--- Returns all the functions of this and parent types.
---@return FicsIt_Networks.Components.Function[] functions The functions this type implements including functions from parent types.
function Struct:getAllFunctions()
end

--- Allows to check if this struct is a child struct of the given struct or given struct it self.
---@param parent FicsIt_Networks.Components.Struct The parent struct you want to check if this struct is a child of.
---@return boolean isChild True of this struct is a child of parent.
function Struct:isChildOf(parent)
end
