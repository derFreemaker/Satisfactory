---@meta

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

----------------------------------------
--- FicsIt-Networks Types
----------------------------------------

---@class float : number

---@class FIN.Class

---@class FIN.Struct

---@class FIN.ItemType

---@class FIN.UUID : string

---@class FIN.Component : FIN.Class
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

---@class FIN.PCIDevice
local PCIDevice = {}
