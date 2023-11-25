---@meta

--- A reflection object representing a struct property.
---@class FIN.Components.StructProperty : FIN.Components.Property
local StructProperty = {}

--- Returns the subclass type of this struct. Meaning, the stored structs need to be of this type.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@return FIN.Components.Struct subclass The subclass of this struct.
function StructProperty:getSubclass()
end
