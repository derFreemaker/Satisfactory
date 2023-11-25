---@meta

--- The base class of ervery object
---@class Satisfactory.Components.Object : FIN.Component
local Object = {}

--- A Hash of this object. This is a value that nearly uniquely identifies this object.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type integer
Object.hash = nil

--- The unreal engine internal name of this object.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type string
Object.internalName = nil

--- The unreal engine internal path name of this object.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type string
Object.internalPath = nil

--- Returns the hash of this class. This is a value that nearly uniquely identifies this object.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@return integer Hash The has of this class.
function Object:getHash()
end

--- Returns the type (aka class) of this class instance
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@return FIN.Components.Class type The type of this class instance
function Object:getType()
end

--- Checks if this Type is a child of the given typen.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param parent Satisfactory.Components.Object The parent we check if this type is a child of.
---@return any returnName True if this type is a child of the given type.
function Object:isChildOf(parent)
end
