---@meta


---@alias FicsIt_Networks.Components.ItemType.Form
---|1 Solid
---|2 Liquid
---|3 Gas
---|4 Heat


--- The type of an item (iron plate, iron rod, leaves)
---@class FicsIt_Networks.Components.ItemType : FicsIt_Networks.Components.Object
---@field form FicsIt_Networks.Components.ItemType.Form The matter state of this resource.
---@field energy float How much energy this resource provides if used as fuel.
---@field radioactiveDecay float The amount of radiation this item radiates.
---@field name string The name of the item.
---@field description string The description of this item.
---@field max integer The maximum stack size of this item.
---@field canBeDiscarded boolean True if this item can be discarded.
---@field category FicsIt_Networks.Components.ItemCategory The category in which this item is in.
---@field fluidColor FicsIt_Networks.Components.Color The color of this fuild.
local ItemType = {}