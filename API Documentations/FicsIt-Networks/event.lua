---@meta

--- **Lua Lib:** `event`
---
--- The Event API provides classes, functions and variables for interacting with the component network.
---@class FIN.Event.Api
event = {}


--- Adds the running lua context to the listen queue of the given component.
---@param component FIN.Component - The network component lua representation the computer should now listen to.
function event.listen(component) end

--- Returns all signal senders this computer is listening to.
---@return FIN.Component[] components - An array containing instances to all sginal senders this computer is listening too.
function event.listening() end

--- Waits for a signal in the queue. Blocks the execution until a signal got pushed to the signal queue, or the timeout is reached.
--- Returns directly if there is already a signal in the queue (the tick doesn’t get yielded).
---@param timeoutSeconds number? - The amount of time needs to pass until pull unblocks when no signal got pushed.
---@return string signalName - The name of the returned signal.
---@return FIN.Component component - The component representation of the signal sender.
---@return any ... - The parameters passed to the signal.
function event.pull(timeoutSeconds) end

--- Removes the running lua context from the listen queue of the given components. Basically the opposite of listen.
---@param component FIN.Component - The network component lua representations the computer should stop listening to.
function event.ignore(component) end

--- Stops listening to any signal sender. If afterwards there are still coming signals in, it might be the system itself or caching bug.
function event.ignoreAll() end

--- Clears every signal from the signal queue.
function event.clear() end
