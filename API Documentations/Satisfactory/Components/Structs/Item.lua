---@meta

--- A structure that holds item information.
---@class Satisfactory.Components.Item : FIN.Struct
local Item = {}

--- The type of the item.
--- ### Flags:
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@type Satisfactory.Components.ItemType
Item.type = nil
