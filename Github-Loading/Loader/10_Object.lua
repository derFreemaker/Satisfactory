---@class Object
---@field protected __add (fun(self: Object, other: any) : any)?
---@field protected __sub (fun(self: Object, other: any) : any)?
---@field protected __mul (fun(self: Object, other: any) : any)?
---@field protected __div (fun(self: Object, other: any) : any)?
---@field protected __mod (fun(self: Object, other: any) : any)?
---@field protected __pow (fun(self: Object, other: any) : any)?
---@field protected __idiv (fun(self: Object, other: any) : any)?
---@field protected __band (fun(self: Object, other: any) : any)?
---@field protected __bor (fun(self: Object, other: any) : any)?
---@field protected __bxor (fun(self: Object, other: any) : any)?
---@field protected __shl (fun(self: Object, other: any) : any)?
---@field protected __shr (fun(self: Object, other: any) : any)?
---@field protected __concat (fun(self: Object, other: any) : any)?
---@field protected __eq (fun(self: Object, other: any) : any)?
---@field protected __lt (fun(self: Object, other: any) : any)?
---@field protected __le (fun(self: Object, other: any) : any)?
---@field protected __unm (fun(self: Object) : any)?
---@field protected __bnot (fun(self: Object) : any)?
---@field protected __len (fun(self: Object) : integer)?
---@field protected __pairs (fun(t):(fun(iterator,t,startPoint):key: any, value: any))?
---@field protected __ipairs (fun(t):(fun(iterator,t,startPoint):key: any, value: any))?
---@field protected __tostring (fun(t):string)?
local Object = {}


---@return string
function Object:GetType()
    local metatable = getmetatable(self)
    return metatable.Type
end

local metatable = {
    Type = "Object",
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