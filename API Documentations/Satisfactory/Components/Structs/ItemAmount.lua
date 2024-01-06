---@meta

--- A struct that holds a pair of amount and item type.
---@class Satisfactory.Components.ItemAmount : FIN.Struct
local ItemAmount = {}

--- The amount of items.
--- ### Flags:
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@type integer
ItemAmount.amount = nil

--- The type of the items.
--- ### Flags:
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@type Satisfactory.Components.ItemType
ItemAmount.type = nil
