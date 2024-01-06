---@meta

--- A structure that holds item information and item amount to represent an item stack.
---@class Satisfactory.Components.ItemStack : FIN.Struct
local ItemStack = {}

--- The count of items.
--- ### Flags:
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@type integer
ItemStack.count = nil

--- The item information of this stack.
--- ### Flags:
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@type Satisfactory.Components.Item
ItemStack.item = nil
