---@class Github_Loading.Entities
local Entities = {}

---@class Github_Loading.Entities.Main
---@field Logger Core.Logger
local Main = {}

---@param mainModule Github_Loading.Entities.Main
---@return Github_Loading.Entities.Main
function Entities.newMain(mainModule)
    local metatable = {
        __index = Main
    }
    return setmetatable(mainModule, metatable)
end

---@return string | any
function Main:Configure()
    return "$%not found%$"
end

---@return string | any
function Main:Run()
    return "$%not found%$"
end

Entities.Main = Main


---@class Github_Loading.Entities.Events
---@field OnLoaded fun()
local Events = {}

---@param loadModule Github_Loading.Entities.Events
---@return Github_Loading.Entities.Events
function Entities.newLoad(loadModule)
    local metatable = {
        __index = Events
    }
    return setmetatable(loadModule, metatable)
end

Entities.Load = Events


return Entities

-- Types and Classes --

---@class Dictionary<K, T>: { [K]: T }


---@class Utils.Class.MetaMethods
---@field __call (fun(self: Object, ...) : ...)?
---@field __gc fun(self: Object)?
---@field __add (fun(self: Object, other: any) : any)? (self) + (value)
---@field __sub (fun(self: Object, other: any) : any)? (self) - (value)
---@field __mul (fun(self: Object, other: any) : any)? (self) * (value)
---@field __div (fun(self: Object, other: any) : any)? (self) / (value)
---@field __mod (fun(self: Object, other: any) : any)? (self) % (value)
---@field __pow (fun(self: Object, other: any) : any)? (self) ^ (value)
---@field __idiv (fun(self: Object, other: any) : any)? (self) // (value)
---@field __band (fun(self: Object, other: any) : any)? (self) & (value)
---@field __bor (fun(self: Object, other: any) : any)? (self) | (value)
---@field __bxor (fun(self: Object, other: any) : any)? (self) ~ (value)
---@field __shl (fun(self: Object, other: any) : any)? (self) << (value)
---@field __shr (fun(self: Object, other: any) : any)? (self) >> (value)
---@field __concat (fun(self: Object, other: any) : any)? (self) .. (value)
---@field __eq (fun(self: Object, other: any) : any)? (self) == (value)
---@field __lt (fun(t1: any, t2: any) : any)? (self) < (value)
---@field __le (fun(t1: any, t2: any) : any)? (self) <= (value)
---@field __unm (fun(self: Object) : any)? -(self)
---@field __bnot (fun(self: Object) : any)?  ~(self)
---@field __len (fun(self: Object) : any)? #(self)
---@field __pairs (fun(t):(fun(iterator,t,startPoint):key: any, value: any))? pairs(self)
---@field __ipairs (fun(t):(fun(iterator,t,startPoint):key: any, value: any))? ipairs(self)
---@field __tostring (fun(t):string)? tostring(self)

---@alias Utils.Class.ConstructorState
---|1 waiting
---|2 running
---|3 finished

---@class Utils.Class.Metatable : Utils.Class.MetaMethods
---@field Type string
---@field Base Object
---@field HasBaseClass boolean
---@field IsBaseClass boolean
---@field HasConstructor boolean
---@field ConstructorState Utils.Class.ConstructorState
---@field HasDeconstructor boolean
---@field HiddenMembers Utils.Class.MetaMethods | table
---@field Index (fun(class, key):any)?
---@field HasIndex boolean
---@field NewIndex (fun(class, key, value))?
---@field HasNewIndex boolean