---@meta

--- **Lua Lib:** `computer`
---
--- The Computer API provides a interface to the computer owns functionalities.
---@class FIN.Computer.Api
computer = {}

--- Returns the current memory usage
---@return integer usage
---@return integer capacity
function computer.getMemory() end

--- Returns the current computer case instance
---@return FIN.Components.ComputerCase_C
function computer.getInstance() end

--- Stops the current code execution immediately and queues the system to restart in the next tick.
function computer.reset() end

--- Stops the current code execution.
--- Basically kills the PC runtime immediately.
function computer.stop() end

--- Crashes the computer with the given error message.
---@param errorMsg string - The crash error message you want to use
function computer.panic(errorMsg) end

--- This function is mainly used to allow switching to a higher tick runtime state. Usually you use this when you want to make your code run faster when using functions that can run in asynchronous environment.
function computer.skip() end

--- Does the same as computer.skip
function computer.promote() end

--- Reverts effects of skip
function computer.demote() end

--- Returns `true` if the tick state is to higher
---@return boolean isPromoted
function computer.isPromoted() end

--- If computer state is async probably after calling computer.skip.
---@return 0 | 1 state - 0 = Sync, 1 = Async
function computer.state() end

--- Lets the computer emit a simple beep sound with the given pitch.
---@param pitch number - The pitch of the beep sound you want to play.
function computer.beep(pitch) end

--- Sets the code of the current eeprom. Doesn’t cause a system reset.
---@param code string - The code you want to place into the eeprom.
function computer.setEEPROM(code) end

--- Returns the code the current eeprom contents.
---@return string code - The code in the EEPROM
function computer.getEEPROM() end

--- Returns the number of game seconds passed since the save got created. A game day consists of 24 game hours, a game hour consists of 60 game minutes, a game minute consists of 60 game seconds.
---@return number time - The number of game seconds passed since the save got created.
function computer.time() end

--- Returns the amount of milliseconds passed since the system started.
---@return integer milliseconds - Amount of milliseconds since system start
function computer.millis() end

--- Returns some kind of strange/mysterious time data from a unknown place (the real life).
---@return integer Timestamp - Unix Timestamp
---@return string DateTimeStamp - Serverside Formatted Date-Time-Stamp
---@return string DateTimeStamp - Date-Time-Stamp after ISO 8601
function computer.magicTime() end

---@param verbosity FIN.Components.LogEntry.Verbosity
---@param format string
---@param ... any
function computer.log(verbosity, format, ...) end

--- This function allows you to get all installed PCI-Devices in a computer of a given type.
---@generic TPCIDevice : FIN.PCIDevice
---@param type TPCIDevice
---@return TPCIDevice[]
function computer.getPCIDevices(type) end

--- Shows a text notification to the player. If player is `nil` to all players.
---@param text string
---@param playerName string?
function computer.textNotification(text, playerName) end

--- Creates an attentionPing at the given position to the player. If player is `nil` to all players.
---@param position Satisfactory.Components.Vector
---@param playerName string?
function computer.attentionPing(position, playerName) end
