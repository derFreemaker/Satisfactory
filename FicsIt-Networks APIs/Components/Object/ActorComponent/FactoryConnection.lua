---@meta


---@alias FicsIt_Networks.Components.FactoryConnection.Type
---|0 Conveyor
---|1 Pipe


---@alias FicsIt_Networks.Components.FactoryConnection.Direction
---|0 Input
---|1 Output
---|2 Any
---|3 Used just as snap point


--- A actor component that os a connection point to which a conveyor or pipr can get attached to.
---@class FicsIt_Networks.Components.FactoryConnection : FicsIt_Networks.Components.ActorComponent
---@field type FicsIt_Networks.Components.FactoryConnection.Type Returns the type of the connection.
---@field direction FicsIt_Networks.Components.FactoryConnection.Direction The direction wich the items/fuilds flow.
---@field isConnected boolean True if something is connected to this connection.
local FactoryConnection = {}


--- Returns the internal inventory of the connection component.
---@return FicsIt_Networks.Components.Inventory inventory The internal inventory of the connection component.
function FactoryConnection:getInventory() end


--- Returns the connected factory connection component.
---@return FicsIt_Networks.Components.Inventory connected The connected factory connection component.
function FactoryConnection:getConnected() end


--- Triggers when the factory connection component transfers an item.
--- **returns from event.pull:**
--- ```
--- local signalName, component, item = event.pull()
--- ```
--- - item: FicsIt_Networks.Components.Item
---@deprecated
---@type FicsIt_Networks.Components.Signal
FactoryConnection.ItemTransfer = { isVarArgs = false }