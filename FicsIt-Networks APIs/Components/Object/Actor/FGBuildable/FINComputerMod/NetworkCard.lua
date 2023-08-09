---@diagnostic disable


---@class FicsIt_Networks.Components.FINComputerMod.NetworkCard : FicsIt_Networks.Components.FINComputerMod
local NetworkCard = {}


--- Sends a network message to the receiver with the given port. The data you want to add can be passed as additional parameters.
--- Max amount of such parameters is 7 and
--- ### they can only be nil, booleans, numbers, and strings. ###
---@param receiver string The component ID as string of the component you want to send the network message to.
---@param port integer The port on which the network message should get sent. For outgoing network messages a port does not need to be opened.
---@param ... any
function NetworkCard:send(receiver, port, ...) end


--- Opens the given port so the network card is able to recieve network messages on the given port.
---@param port integer The port you want to open.
function NetworkCard:open(port) end


--- Closes all the ports of the network card so no further messages are able to get received
function NetworkCard:closeAll() end


--- Closes the given port so the network card wont recieve network messages on the given port.
---@param port integer The port you want to close.
function NetworkCard:close(port) end


--- Sends a network message to all components in the network message network (including networks sepperated by routers) on the given port.
--- The data you want to add can be passed as additional parameters.
--- Max amount of such parameters is 7 and
--- ### they can only be nil, booleans, numbers, and strings. ###
---@param port integer The port on which the network message should get sent. For outgoing network messages a port does not need to be opened.
function NetworkCard:broadcast(port) end


--- Triggers when the network card receives a network message on one of its opened ports. The additional arguments are the data that is contained within the network message.
--- **Additional returns of event.pull:**
--- ```
--- local signalName, component, sender, port, ... = event.pull()
--- ```
--- - sender: string -> The component id of the sender of the network message.
--- - port: integer -> The port on which the network message got sent.
--- - ... data -> The 7 addtional parameters if some were sent.
---@type FicsIt_Networks.Components.Signal
NetworkCard.NetworkMessage = {}


--- The FicsIt Networks Card allows yout to send network messages to other network cards in the same computer network. <br>
--- You can use unicast and broadcast messages to share information between multiple different computers in the same network. <br>
--- This is the best and easiest way for you to communicate between multiple computers. <br>
--- If you want to recieve network messages, make sure you also open the according port, since every message is asscoiated with a port allowing for better filtering.
---@class FicsIt_Networks.Components.FINComputerMod.NetworkCard_C : FicsIt_Networks.Components.FINComputerMod.NetworkCard
local NetworkCard_C = {}