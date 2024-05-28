local luaunit = require("Tools.Testing.Luaunit")
local functions = require("Tools.Testing.Functions")
require("Tools.Testing.Simulator.init"):Initialize(1)

local UUID = require("Core.Common.UUID")

function TestNewUUIDBenchmark()
    local test = UUID.Static__New
    functions.benchmarkFunction(test, 100000)
end

function TestEmptyUUIDBenchmark()
    local function getEmpty()
        _ = UUID.Static__Empty
    end
    functions.benchmarkFunction(getEmpty, 1000000)
end

function TestParseUUIDBenchmark()
    functions.benchmarkFunction(
        function()
            UUID.Static__Parse("000000-0000-000000")
        end,
        100000
    )
end

os.exit(luaunit.LuaUnit.run())
