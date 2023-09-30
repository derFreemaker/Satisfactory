---@meta

--- A actor component that can hold multiple item stacks.
---@class FicsIt_Networks.Components.Inventory : FicsIt_Networks.Components.ActorComponent
local Inventory = {}

--- True if items can be moved between the slots feely.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type boolean
Inventory.canRearange = nil

--- The absolute amount of items in the whole inventory.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type integer
Inventory.itemCount = nil

--- The count of available item stack slots this inventory has.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type integer
Inventory.size = nil

--- Returns the item stack at the given index.
--- Takes integers as input and returns the corresponding stacks.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Variable Arguments - Can have any additional arguments as described.
---@param ... integer
---@return FicsIt_Networks.Components.ItemStack ...
function Inventory:getStack(...)
end

--- Sorts the whole inventory. (like the middle mouse click into a inventory)
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
function Inventory:sort()
end

--- Removes all discardable items from the inventory completely. They will be gone! No way to get them back!
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
function Inventory:flush()
end

--- Returns true of the stack at the given index can be split.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param index integer The index of the item stack that you want check if can be split.
---@return boolean canSplit True if the item stack can be split.
function Inventory:canSplitStackAtIndex(index)
end

--- Splits the stack at hthe given index into two. The passed amount of items gets transfered to the next available slot.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param index integer The index of the slot whichs stack you want to split.
---@param itemCount integer The count of items that should get transfered to the next available slot.
function Inventory:splitStackAtIndex(index, itemCount)
end

--- Moves the stack of the given slot to another given slot. If partial is allowed, only moves as much items as possible, if not allowed, and the full stack doesnt fit onto the new slot, skips the move.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
---@param fromIndex integer Index of the slot from where you want to take the stack.
---@param toIndex integer Index of the slot you want to move the stack to.
---@param allowPartial boolean Pass true if only partial item stack moving is allowed.
---@return integer count The count of items that have been moved.
function Inventory:moveItemStack(fromIndex, toIndex, allowPartial)
end
