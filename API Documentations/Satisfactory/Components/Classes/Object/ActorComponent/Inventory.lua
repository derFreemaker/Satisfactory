---@meta

--- A actor component that can hold multiple item stacks.
--- WARNING! Be aware of container inventories, and never open their UI, otherwise these functions will not work as expected.
---@class Satisfactory.Components.Inventory : Satisfactory.Components.ActorComponent
local Inventory = {}

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
---@return Satisfactory.Components.ItemStack ...
function Inventory:getStack(...)
end

--- Sorts the whole inventory. (like the middle mouse click into a inventory)
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
function Inventory:sort()
end

--- Swaps tow given stacks inside the inventory.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param index1 integer The index of the first stack in the inventory.
---@param index2 integer The index of the second stack in the inventory.
---@return boolean successful Trus if the swap was successful.
function Inventory:swapStacks(index1, index2)
end

--- Removes all discardable items from the inventory completely. They will be gone! No way to get them back!
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
function Inventory:flush()
end
