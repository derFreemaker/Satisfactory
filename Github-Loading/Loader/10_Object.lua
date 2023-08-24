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
---@field protected __pairs (fun(self: object) : (fun(iterator, t, startPoint) : key: any, value: any))? pairs(self)
---@field protected __ipairs (fun(self: object) : (fun(iterator, t, startPoint) : key: any, value: any))? ipairs(self)
---@field protected __tostring (fun(self: object) : string)? tostring(self)

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

return setmetatable(Object, metatable) --[[@as object]]