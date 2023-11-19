---@meta

--- [Documentation](https://docs.ficsit.app/ficsit-networks/latest/index.html)
--- [Code](https://github.com/Panakotta00/FicsIt-Networks/tree/master)
--- Date: 08.09.2023

--#region global variables

--- # Not in FicsIt-Networks available #
package = nil

--- # Not in FicsIt-Networks available #
os = nil

--- # Not in FicsIt-Networks available #
collectgarbage = nil

--- # Not in FicsIt-Networks available #
io = nil

--- # Not in FicsIt-Networks available #
arg = nil

--- # Not in FicsIt-Networks available #
require = nil

--#endregion

--#region FicsIt-Networks types

---@class float : number

---@class FIN.Class

---@class FIN.ItemType

---@class FIN.UUID : string

---@class FIN.Component
local Component = {}

--- The network id of this component.
---
--- ## Only on objects that are network components.
--- ### Flags:
--- * ? Runtime Synchronous - Can be called/changed in Game Tick ?
--- * ? Runtime Parallel - Can be called/changed in Satisfactory Factory Tick ?
--- * Read Only - The value of this property can not be changed by code
---@type FIN.UUID
Component.id = nil

--- The nick you gave the component in the network its in.
--- If it has no nick name it returns `nil`.
---
--- ## Only on objects that are network components.
--- ### Flags:
--- * ? Runtime Synchronous - Can be called/changed in Game Tick ?
--- * ? Runtime Parallel - Can be called/changed in Satisfactory Factory Tick ?
--- * Read Only - The value of this property can not be changed by code
---@type string
Component.nick = nil

--#endregion

--#region functions

--- Tries to find an object type with the given name, and returns the found type.
---@param name string
---@return FIN.Class Class
function findClass(name)
end

--- Tries to find a structure type with the given name, and returns the found type.
---@param name string
---@return FIN.Class Class
function findStruct(name)
end

--- Tries to find an item type with the given name, and returns the found item type.
---@param name string
---@return FIN.ItemType ItemType
function findItem(name)
end

--#endregion
