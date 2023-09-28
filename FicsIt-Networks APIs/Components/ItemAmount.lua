---@meta

--- A struct that holds a pair of amount and item type.
---@class FicsIt_Networks.Components.ItemAmount
local ItemAmount = {}

--- The amount of items.
--- ### Flags:
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@type integer
ItemAmount.amount = nil

--- The type of the items.
--- ### Flags:
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@type FicsIt_Networks.Components.ItemType
ItemAmount.type = nil
