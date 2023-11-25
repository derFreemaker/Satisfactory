---@meta

--- Reflection Object that holds information about structures.
---@class FIN.Components.Struct : FIN.Components.ReflectionBase
local Struct = {}

--- True if this struct can be constructed by the user directly.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type boolean
Struct.isConstructable = nil

--- Returns the parent type of this type
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
---@return FIN.Components.Class parent The parent type of this type.
function Struct:getParent()
end

--- Returns all the properties of this type.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@return FIN.Components.Property[] properties The properties this specific type implements (excluding properties from parent types).
function Struct:getProperties()
end

--- Returns all the properties of this and parent types.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@return FIN.Components.Property[] properties The properties this type implements including properties from parent types.
function Struct:getAllProperties()
end

--- Returns all the functions of this type.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@return FIN.Components.Function[] functions The functions this specific type implements (excluding functions from parent types).
function Struct:getFunctions()
end

--- Returns all the functions of this and parent types.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@return FIN.Components.Property[] functions The functions this type implements including functions from parent types.
function Struct:getAllFunctions()
end

--- Allows to check if this struct is a child struct of the given struct or given struct it self.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@param parent FIN.Components.Struct The parent struct you want to check if this struct is a child of.
---@return boolean isChild True of this struct is a child of parent.
function Struct:isChildOf(parent)
end
