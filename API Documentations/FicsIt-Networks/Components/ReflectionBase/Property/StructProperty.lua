---@meta

--- A reflection object representing a struct property.
---@class FicsIt_Networks.Components.StructProperty : FicsIt_Networks.Components.Property
local StructProperty = {}

--- Returns the subclass type of this struct. Meaning, the stored structs need to be of this type.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@return FicsIt_Networks.Components.Struct subclass The subclass of this struct.
function StructProperty:getSubclass()
end
