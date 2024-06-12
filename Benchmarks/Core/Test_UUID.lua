local luaunit = require("Tools.Testing.Luaunit")
local functions = require("Tools.Testing.Functions")
require("Tools.Testing.Simulator.init"):Initialize(1)

local UUID = require("Core.Common.UUID")

function TestNewUUIDBenchmark()
    functions.benchmarkFunction(
        function()
            _ = UUID.Static__New()
        end,
        100000
    )
end

function TestEmptyUUIDBenchmark()
    functions.benchmarkFunction(
        function ()
            _ = UUID.Static__Empty
        end,
        10000
    )
end

function TestParseUUIDBenchmark()
    functions.benchmarkFunction(
        function()
            UUID.Static__Parse("000000-0000-000000")
        end,
        100000
    )
end

function TestToStringUUIDBenchmark()
    local uuid = UUID.Static__New()
    
    functions.benchmarkFunction(
        function ()
            _ = uuid:ToString()
        end,
        100000
    )
end

os.exit(luaunit.LuaUnit.run())
