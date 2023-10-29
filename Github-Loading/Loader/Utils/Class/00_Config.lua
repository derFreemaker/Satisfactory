---@class Utils.Class.Configs
local Configs = {}

Configs.AllMetaMethods = {
    --- Constructor
    __init = true,
    --- Garbage Collection
    __gc = true,

    --- Special
    __call = true,
    __newindex = true,
    __index = true,
    __pairs = true,
    __ipairs = true,
    __tostring = true,

    -- Operators
    __add = true,
    __sub = true,
    __mul = true,
    __div = true,
    __mod = true,
    __pow = true,
    __unm = true,
    __idiv = true,
    __band = true,
    __bor = true,
    __bxor = true,
    __bnot = true,
    __shl = true,
    __shr = true,
    __concat = true,
    __len = true,
    __eq = true,
    __lt = true,
    __le = true
}

Configs.OverrideMetaMethods = {
    __pairs = true,
    __ipairs = true
}

Configs.IndirectMetaMethods = {
    __index = true,
    __newindex = true
}

Configs.SetNormal = {}
Configs.SearchInBase = {}

return Configs
