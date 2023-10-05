---@class Utils.Class.ObjectMetaMethods
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
---@field protected __pairs (fun(self: object) : ((fun(self: object, key: any) : key: any, value: any), self: object, startPoint: any))? pairs(self)
---@field protected __ipairs (fun(self: object) : ((fun(self: object, key: integer) : key: integer, value: any), self: object, startPoint: integer))? ipairs(self)
---@field protected __tostring (fun(self: object) : string)? tostring(self)
---@field protected __call (function)? self()
---@field protected __init (function)? constructor
---@field protected __gc (fun())? deconstructor
---@field protected __index fun(class, key) : any
---@field protected __newindex fun(class, key, value)

---@class object : Utils.Class.ObjectMetaMethods
local Object = {}


---@return string
function Object:GetType()
    ---@type Utils.Class.Metatable
    local metatable = getmetatable(self)
    return metatable.Type
end

local metatable = {
    Type = "object",
    HasDeconstructor = false,
    HasConstructor = false,
    ConstructorState = "waiting",
    __call = function(self)
        local metatable = getmetatable(self)
        metatable.__call = nil
        metatable.ConstructorState = "running"
        for key, value in pairs(metatable.Functions) do
            self[key] = value
        end
        for key, value in pairs(metatable.Properties) do
            self[key] = value
        end
        metatable.Properties = nil
        metatable.ConstructorState = "finished"
        return self
    end,
    __gc = function(self)
        local metatable = getmetatable(self)
        metatable.__gc = nil
        metatable.ConstructorState = "deconstructed"
    end,
    HiddenMembers = {},
    MetaMethods = {},
    Functions = {},
    Properties = {}
}

for key, value in pairs(Object) do
    if type(value) == "function" then
        metatable.Functions[key] = value
    else
        metatable.Properties[key] = value
    end
    Object[key] = nil
end

return setmetatable(Object, metatable) --[[@as object]]
