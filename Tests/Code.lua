local _, logger = require('Tests.Simulator.Simulator'):Initialize(1)

local args = { "hi1", "hi2" }
local args2 = { "hi3", "hi4" }

function foo2(...)
    print(...)
end

function foo(...)
    print(...)
    return ...
end

foo2(foo(table.unpack(args)), table.unpack(args2, 1, #args2))
