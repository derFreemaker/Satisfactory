---@meta

---@alias FIN.Components.LogEntry.Verbosity
---|0 Debug
---|1 Info
---|2 Warning
---|3 Error
---|4 Fatal
---|5 Max

--- An entry in the Computer Log.
---@class FIN.Components.LogEntry : FIN.Struct
local LogEntry = {}

--- The Message-Content contained within the log entry.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type string
LogEntry.content = nil

--- The timestamp at which the log entry got logged.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type string
LogEntry.timestamp = nil

--- # Property
--- Description
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type FIN.Components.LogEntry.Verbosity
LogEntry.verbosity = nil

--- Creates a formatted string representation of this log entry.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return string result The resulting formatted string
function LogEntry:format() end
