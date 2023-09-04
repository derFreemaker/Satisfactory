---@meta

---@class FicsIt_Networks.Components.ComputerCase : FicsIt_Networks.Components.FGBuildable
local ComputerCase = {}


--- Triggers when something in the filesystem changes.
--- **returns from event.pull:**
--- ```
--- local signalName, component, updateType, from, to = event.pull()
--- ```
--- - updateType: integer -> The type of the change.
--- - from: string The file path to the FS node that has changed.
--- - to: string The new file path of the node if it has changed.
---@deprecated
---@type FicsIt_Networks.Components.Signal
ComputerCase.FileSystemUpdate = { isVarArgs = false }


--- The FicsIt-Network computer case is the most important thing you will know of. This case already holds the essentials of a computer for you.
--- Like a network connector, keyboard, mouse, screen. But most important of all, it already has a motherboard were you can place and configure the computer just like you want.
---@class FicsIt_Networks.Components.ComputerCase_C : FicsIt_Networks.Components.ComputerCase