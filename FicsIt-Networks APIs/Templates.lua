---@meta

--- Template class Description
---@class Template
local Template

--- # Property
--- Description
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type any
Template.X = nil

--- # Function
--- Description
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@param test any Description parameter 1
---@return any returnName Description return parameter
function Template:test(test)
end

--- # Signal
--- Triggers when the network card receives a network message on one of its opened ports. The additional arguments are the data that is contained within the network message.
---
--- ### returns from event.pull:
--- ```
--- local signalName, component, test, ... = event.pull()
--- ```
--- - `test: string` -> The component id of the sender of the network message.
--- - `...: any` -> addtional parameters
---@deprecated
---@type FicsIt_Networks.Components.Signal
Template.NetworkMessage = {isVarArgs = true}
