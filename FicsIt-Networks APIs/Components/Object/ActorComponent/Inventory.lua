---@meta


--- A actor component that can hold multiple item stacks.
---@class FicsIt_Networks.Components.Inventory : FicsIt_Networks.Components.ActorComponent
---@field itemCount integer The absolute amount of items in the whole inventory.
---@field size integer The count of available item stack slots this inventory has.
local Inventory = {}


--- Returns the item stack at the given index.
--- Takes integers as input and returns the corresponding stacks.
---@param ... integer
---@return FicsIt_Networks.Components.ItemStack ...
function Inventory:getStack(...) end


--- Sorts the whole inventory. (like the middle mouse click into a inventory)
function Inventory:sort() end


--- Removes all discardable items from the inventory completely. They will be gone! No way to get them back!
function Inventory:flush() end