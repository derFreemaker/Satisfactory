---@meta

---@alias FIN.Components.Property.DataType
---|0 nil
---|1 boolean
---|2 integer
---|3 float
---|4 string
---|5 object
---|6 class
---|7 trace
---|8 struct
---|9 array
---|10 anything

--- Bits and their meaning (least significant bit first)
---@alias FIN.Components.Property.Flags
---|0 Is this property a member attribute.
---|1 Is this property a read only.
---|2 Is this property a parameter.
---|3 Is this property a output parameter.
---|4 Is this property a return value.
---|5 Can this property get accessed in syncrounus runtime.
---|6 Can this property can get accessed in parallel runtime.
---|7 Can this property get accessed in asynchronus runtime.
---|8 This property is a class attribute.

--- A Reflection object that holds information about properties and parameters.
---@class FIN.Components.Property
local Property = {}

--- The data type of this property.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type FIN.Components.Property.DataType
Property.dataType = nil

--- The property bit flag register defining some behaviour of it.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type FIN.Components.Property.Flags
Property.flags = nil
