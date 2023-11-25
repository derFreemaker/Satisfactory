---@meta

--- The category of some items.
---@class Satisfactory.Components.ItemCategory : Satisfactory.Components.Object
local ItemCategory = {}

--- The name of the category.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type string
ItemCategory.name = nil
