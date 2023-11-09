---@meta


---@class Utils.Class.ObjectMetaMethods
---@field protected __init (fun(self: object, ...))? self(...) before construction
---@field protected __call (fun(self: object, ...) : ...)? self(...) after construction
---@field protected __close (fun(self: object, errobj: any) : any)? invoked when the object gets out of scope
---@field protected __gc fun(self: object)? Utils.Class.Deconstruct(self) or garbageCollection
---@field protected __add (fun(self: object, other: any) : any)? (self) + (value)
---@field protected __sub (fun(self: object, other: any) : any)? (self) - (value)
---@field protected __mul (fun(self: object, other: any) : any)? (self) * (value)
---@field protected __div (fun(self: object, other: any) : any)? (self) / (value)
---@field protected __mod (fun(self: object, other: any) : any)? (self) % (value)
---@field protected __pow (fun(self: object, other: any) : any)? (self) ^ (value)
---@field protected __idiv (fun(self: object, other: any) : any)? (self) // (value)
---@field protected __band (fun(self: object, other: any) : any)? (self) & (value)
---@field protected __bor (fun(self: object, other: any) : any)? (self) | (value)
---@field protected __bxor (fun(self: object, other: any) : any)? (self) ~ (value)
---@field protected __shl (fun(self: object, other: any) : any)? (self) << (value)
---@field protected __shr (fun(self: object, other: any) : any)? (self) >> (value)
---@field protected __concat (fun(self: object, other: any) : any)? (self) .. (value)
---@field protected __eq (fun(self: object, other: any) : any)? (self) == (value)
---@field protected __lt (fun(t1: any, t2: any) : any)? (self) < (value)
---@field protected __le (fun(t1: any, t2: any) : any)? (self) <= (value)
---@field protected __unm (fun(self: object) : any)? -(self)
---@field protected __bnot (fun(self: object) : any)?  ~(self)
---@field protected __len (fun(self: object) : any)? #(self)
---@field protected __pairs (fun(t: table) : ((fun(t: table, key: any) : key: any, value: any), t: table, startKey: any))? pairs(self)
---@field protected __ipairs (fun(t: table) : ((fun(t: table, key: number) : key: number, value: any), t: table, startKey: number))? ipairs(self)
---@field protected __tostring (fun(t):string)? tostring(self)
---@field protected __index (fun(class, key) : any)? xxx = self.xxx | self[xxx]
---@field protected __newindex fun(class, key, value)? self.xxx = xxx | self[xxx] = xxx

---@class Utils.Class.MetaMethods
---@field __init (fun(self: object, ...))? self(...) before construction
---@field __gc fun(self: object)? Class.Deconstruct(self) or garbageCollection
---@field __close (fun(self: object, errobj: any) : any)? invoked when the object gets out of scope
---@field __call (fun(self: object, ...) : ...)? self(...) after construction
---@field __index (fun(class: object, key: any) : any)? xxx = self.xxx | self[xxx]
---@field __newindex fun(class: object, key: any, value: any)? self.xxx | self[xxx] = xxx
---@field __tostring (fun(t):string)? tostring(self)
---@field __add (fun(left: any, right: any) : any)? (left) + (right)
---@field __sub (fun(left: any, right: any) : any)? (left) - (right)
---@field __mul (fun(left: any, right: any) : any)? (left) * (right)
---@field __div (fun(left: any, right: any) : any)? (left) / (right)
---@field __mod (fun(left: any, right: any) : any)? (left) % (right)
---@field __pow (fun(left: any, right: any) : any)? (left) ^ (right)
---@field __idiv (fun(left: any, right: any) : any)? (left) // (right)
---@field __band (fun(left: any, right: any) : any)? (left) & (right)
---@field __bor (fun(left: any, right: any) : any)? (left) | (right)
---@field __bxor (fun(left: any, right: any) : any)? (left) ~ (right)
---@field __shl (fun(left: any, right: any) : any)? (left) << (right)
---@field __shr (fun(left: any, right: any) : any)? (left) >> (right)
---@field __concat (fun(left: any, right: any) : any)? (left) .. (right)
---@field __eq (fun(left: any, right: any) : any)? (left) == (right)
---@field __lt (fun(left: any, right: any) : any)? (left) < (right)
---@field __le (fun(left: any, right: any) : any)? (left) <= (right)
---@field __unm (fun(self: object) : any)? -(self)
---@field __bnot (fun(self: object) : any)?  ~(self)
---@field __len (fun(self: object) : any)? #(self)
---@field __pairs (fun(self: object) : ((fun(t: table, key: any) : key: any, value: any), t: table, startKey: any))? pairs(self)
---@field __ipairs (fun(self: object) : ((fun(t: table, key: number) : key: number, value: any), t: table, startKey: number))? ipairs(self)


---@class Utils.Class.Type
---@field Name string
---@field Base Utils.Class.Type
---
---@field Static table<string, any>
---
---@field MetaMethods Utils.Class.MetaMethods
---@field Members table<string, any>
---
---
---@field HasConstructor boolean
---@field HasDeconstructor boolean
---
---@field IndexingDisabled boolean
---@field HasIndex boolean
---@field HasNewIndex boolean
---
---@field Template table
---@field Instances table<Utils.Class.Instance, boolean>


---@class Utils.Class.Metatable : Utils.Class.MetaMethods
---@field Type Utils.Class.Type


---@class Utils.Class.Template


---@class Utils.Class.Instance : table
