---@meta

---@class FIN.Components.ComputerCase : Satisfactory.Components.Buildable
local ComputerCase = {}

--- Stops the Computer (Processor).
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
function ComputerCase:stopComputer()
end

--- Starts the Computer (Processor).
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
function ComputerCase:startComputer()
end

--- Returns the internal kernel state of the computer.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return integer result The current internal kernel state.
function ComputerCase:getState()
end

--- Returns the log of the computer. Output is paginated using input parameters. A negative Page will indicate pagination from the bottom (latest log entry first).
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param pageSite integer The size of the returned page.
---@param page integer The index of the page you want to return. Negative to start indexing at the bottom (latest entries first).
---@return FIN.Components.LogEntry[] log The Log page you wanted to retrieve.
---@return integer logSize The size of the full log (not just the returned page).
function ComputerCase:getState(pageSite, page)
end

--- Triggers when something in the filesystem changes.
--- ### returns from event.pull:
--- ```
--- local signalName, component, updateType, from, to = event.pull()
--- ```
--- - `signalName: string` <br> -> "FileSystemUpdate"
--- - `component: FIN.Components.ComputerCase_C` <br> -> The component wich send the signal.
--- - `updateType: integer` <br> -> The type of the change.
--- - `from: string` <br> -> The file path to the FS node that has changed.
--- - `to: string` <br> -> The new file path of the node if it has changed.
---@deprecated
---@type FIN.Components.Signal
ComputerCase.FileSystemUpdate = { isVarArgs = false }

--- Triggers when the computers state changes.
---
--- ### returns from event.pull:
--- ```
--- local signalName, component, prevState, newState = event.pull()
--- ```
--- - `signalName: string` <br> -> "ComputerStateChanged"
--- - `component: Template` <br> -> The component wich send the signal.
--- - `prevState: integer` <br> -> The previous computer state.
--- - `newState: integer` <br> -> The new computer state.
---@deprecated
---@type FIN.Components.Signal
ComputerCase.ComputerStateChanged = { isVarArgs = false }
