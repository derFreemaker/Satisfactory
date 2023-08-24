---@class Utils.Class.ObjectMetaMethods
---@field protected __add (fun(self: Object, other: any) : any)? (self) + (value)
---@field protected __sub (fun(self: Object, other: any) : any)? (self) - (value)
---@field protected __mul (fun(self: Object, other: any) : any)? (self) * (value)
---@field protected __div (fun(self: Object, other: any) : any)? (self) / (value)
---@field protected __mod (fun(self: Object, other: any) : any)? (self) % (value)
---@field protected __pow (fun(self: Object, other: any) : any)? (self) ^ (value)
---@field protected __idiv (fun(self: Object, other: any) : any)? (self) // (value)
---@field protected __band (fun(self: Object, other: any) : any)? (self) & (value)
---@field protected __bor (fun(self: Object, other: any) : any)? (self) | (value)
---@field protected __bxor (fun(self: Object, other: any) : any)? (self) ~ (value)
---@field protected __shl (fun(self: Object, other: any) : any)? (self) << (value)
---@field protected __shr (fun(self: Object, other: any) : any)? (self) >> (value)
---@field protected __concat (fun(self: Object, other: any) : any)? (self) .. (value)
---@field protected __eq (fun(self: Object, other: any) : any)? (self) == (value)
---@field protected __lt (fun(t1: any, t2: any) : any)? (self) < (value)
---@field protected __le (fun(t1: any, t2: any) : any)? (self) <= (value)
---@field protected __unm (fun(self: Object) : any)? -(self)
---@field protected __bnot (fun(self: Object) : any)?  ~(self)
---@field protected __len (fun(self: Object) : any)? #(self)
---@field protected __pairs (fun(self: Object) : (fun(iterator, t, startPoint) : key: any, value: any))? pairs(self)
---@field protected __ipairs (fun(self: Object) : (fun(iterator, t, startPoint) : key: any, value: any))? ipairs(self)
---@field protected __tostring (fun(self: Object) : string)? tostring(self)

-- //TODO: change Object to object

---@class Object : Utils.Class.ObjectMetaMethods
local Object = {}


---@return string
function Object:GetType()
    ---@type Utils.Class.Metatable
    local metatable = getmetatable(self)
    return metatable.Type
end


local metatable = {
    Type = "object",
    HasBaseClass = false,
    HasDeconstructor = false,
    HasConstructor = false,
    ConstructorState = 1,
    __call = function(obj)
        local metatable = getmetatable(obj)
        metatable.__call = nil
        metatable.ConstructorState = 2
        for key, value in pairs(metatable.HiddenMembers) do
            obj[key] = value
        end
        metatable.HiddenMembers = nil
        metatable.ConstructorState = 3
        return obj
    end,
    HiddenMembers = {}
}

for key, value in pairs(Object) do
    metatable.HiddenMembers[key] = value
    Object[key] = nil
end

return setmetatable(Object, metatable) --[[@as Object]]