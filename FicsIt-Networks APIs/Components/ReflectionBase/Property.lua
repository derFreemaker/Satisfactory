---@diagnostic disable

---@alias FicsIt_Networks.Components.Property.DataType
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
---@alias FicsIt_Networks.Components.Property.Flags
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
---@class FicsIt_Networks.Components.Property
---@field dataType FicsIt_Networks.Components.Property.DataType The data type of this property.
---@field flags FicsIt_Networks.Components.Property.Flags The property bit flag register defining some behaviour of it.
local Property = {}