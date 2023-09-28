---@meta

--- A structure that holds item information and item amount to represent an item stack.
---@class FicsIt_Networks.Components.ItemStack
local ItemStack = {}

--- The count of items.
--- ### Flags:
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@type integer
ItemStack.count = nil

--- The item information of this stack.
--- ### Flags:
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@type FicsIt_Networks.Components.Item
ItemStack.item = nil
