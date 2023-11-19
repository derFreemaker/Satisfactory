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
Template.property = nil

--- # Function
--- Description
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Variable Arguments - Can have any additional arguments as described.
---@param test any Description parameter 1
---@return any returnName Description return parameter
function Template:functionTemplate(test)
end

--- # Signal
--- Description
---
--- ### returns from event.pull:
--- ```
--- local signalName, component, test, ... = event.pull()
--- ```
--- - `signalName: string` <br> -> "Signal"
--- - `component: Template` <br> -> The component wich send the signal.
--- - `test: string` <br> -> description
--- - `...: any` <br> -> addtional parameters
---@deprecated
---@type FIN.Components.Signal
Template.Signal = { isVarArgs = true }
