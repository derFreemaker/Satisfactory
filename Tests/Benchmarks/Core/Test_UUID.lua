local luaunit = require('Tests.Luaunit')
local functions = require("Tests.Functions")
require('Tests.Simulator.Simulator'):Initialize(1)

local UUID = require('Core.Common.UUID')

function TestNewUUIDBenchmark()
    functions.benchmarkFunction(UUID.Static__New, 100000)
end

function TestEmptyUUIDBenchmark()
    functions.benchmarkFunction(UUID.Static__Empty, 10000000)
end

function TestParseUUIDBenchmark()
    functions.benchmarkFunction(
        function()
            UUID.Static__Parse('000000-0000-000000')
        end,
        100000
    )
end

os.exit(luaunit.LuaUnit.run())
