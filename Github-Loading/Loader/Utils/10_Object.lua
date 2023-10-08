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
