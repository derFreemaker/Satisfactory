---@meta

---@class FIN.Components.NetworkCard : FIN.Components.FINComputerModule, FIN.PCIDevice
local NetworkCard = {}

--- Sends a network message to the receiver with the given port. The data you want to add can be passed as additional parameters.
--- Max amount of such parameters is 7 and
--- ### they can only be nil, booleans, numbers, and strings.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Variable Arguments - Can have any additional arguments as described.
---@param receiver string The component ID as string of the component you want to send the network message to.
---@param port integer The port on which the network message should get sent. For outgoing network messages a port does not need to be opened.
---@param ... any
function NetworkCard:send(receiver, port, ...)
end

--- Opens the given port so the network card is able to recieve network messages on the given port.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param port integer The port you want to open.
function NetworkCard:open(port)
end

--- Closes all the ports of the network card so no further messages are able to get received
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
function NetworkCard:closeAll()
end

--- Closes the given port so the network card wont recieve network messages on the given port.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param port integer The port you want to close.
function NetworkCard:close(port)
end

--- Sends a network message to all components in the network message network (including networks sepperated by routers) on the given port.
--- The data you want to add can be passed as additional parameters.
--- Max amount of such parameters is 7 and
--- ### they can only be nil, booleans, numbers, and strings.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Variable Arguments - Can have any additional arguments as described.
---@param port integer The port on which the network message should get sent. For outgoing network messages a port does not need to be opened.
---@param ... any
function NetworkCard:broadcast(port, ...)
end

--- Triggers when the network card receives a network message on one of its opened ports. The additional arguments are the data that is contained within the network message.
---
--- ### returns from event.pull:
--- ```
--- local signalName, component, sender, port, ... = event.pull()
--- ```
--- - `signalName: string` <br> -> "NetworkMessage"
--- - `component: FIN.Components.FINComputerMod.NetworkCard_C` <br> -> The component wich send the signal.
--- - `sender: string` <br> -> The component id of the sender of the network message.
--- - `port: integer` <br> -> The port on which the network message got sent.
--- - `...: nil | booleans | numbers | string` <br> -> The 7 addtional parameters if some were sent.
---@deprecated
---@type FIN.Components.Signal
NetworkCard.NetworkMessage = { isVarArgs = true }
