---@diagnostic disable

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

---@class FicsIt_Networks.Class

---@class FicsIt_Networks.ItemType

---@class FicsIt_Networks.UUID : string

---@class FicsIt_Networks.Component : table

--#endregion

--#region functions

--- Tries to find an object type with the given name, and returns the found type.
---@param name string
---@return FicsIt_Networks.Class Class
function findClass(name) end


--- Tries to find a structure type with the given name, and returns the found type.
---@param name string
---@return FicsIt_Networks.Class Class
function findStruct(name) end


--- Tries to find an item type with the given name, and returns the found item type.
---@param name string
---@return FicsIt_Networks.ItemType ItemType
function findItem(name) end

--#endregion