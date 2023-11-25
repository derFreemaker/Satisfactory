---@meta

---@alias Satisfactory.Components.FactoryConnection.Type
---|0 Conveyor
---|1 Pipe

---@alias Satisfactory.Components.FactoryConnection.Direction
---|0 Input
---|1 Output
---|2 Any
---|3 Used just as snap point

--- A actor component that os a connection point to which a conveyor or pipr can get attached to.
---@class Satisfactory.Components.FactoryConnection : Satisfactory.Components.ActorComponent
local FactoryConnection = {}

--- Returns the type of the connection.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type Satisfactory.Components.FactoryConnection.Type
FactoryConnection.type = nil

--- The direction wich the items/fuilds flow.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type Satisfactory.Components.FactoryConnection.Direction
FactoryConnection.direction = nil

--- True if something is connected to this connection.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type boolean
FactoryConnection.isConnected = nil

--- This item type defines which items are the only ones this connector can transfer. Null allows all items to be transfered.
--- ### Flags:
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@type Satisfactory.Components.ItemType
FactoryConnection.allowedItem = nil

--- True if this connector doesn't transfer any items except the 'Unblocked Transfers'.
--- ### Flags:
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@type boolean
FactoryConnection.blocked = nil

--- The count of transfers taht can still happen even if the connector is blocked. Use the 'AddUnblockedTransfers' function to change this. The count decreases by one when an item gets transfered.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type integer
FactoryConnection.unblockedTransfers = nil

--- Adds the given count of the unblocked transfers counter. The resulting value gets clamped to >= 0. Negative vales allow to decrease the counter manually.
---The returning int is the now set count.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param unblockedTransfers integer The count of unblocked transfers to add.
---@return integer newUnblockedTransfers The new count of unblocked transfers.
function FactoryConnection:addUnblockedTransfers(unblockedTransfers)
end

--- Returns the internal inventory of the connection component.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@return Satisfactory.Components.Inventory inventory The internal inventory of the connection component.
function FactoryConnection:getInventory()
end

--- Returns the connected factory connection component.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@return Satisfactory.Components.Inventory connected The connected factory connection component.
function FactoryConnection:getConnected()
end

--- Triggers when the factory connection component transfers an item.
---
--- ### returns from event.pull:
--- ```
--- local signalName, component, item = event.pull()
--- ```
--- - `signalName: string` <br> -> "ItemTransfer"
--- - `component: FIN.Components.FactoryConnection` <br> -> The component wich send the signal.
--- - `item: FIN.Components.Item` <br> -> The transferd item
---@deprecated
---@type FIN.Components.Signal
FactoryConnection.ItemTransfer = { isVarArgs = false }
