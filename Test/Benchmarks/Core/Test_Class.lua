local luaunit = require('Test.Luaunit')
require('Test.Simulator.Simulator')

---@param func function
---@param amount integer
local function benchmarkFunction(func, amount)
    local startTime = os.clock()

    for i = 1, amount, 1 do
        func(i)
    end

    local endTime = os.clock()

    local totalTime = endTime - startTime

    print('total time: ' .. totalTime .. 's amount: ' .. amount)
    print('each time : ' .. (totalTime / amount) * 1000 * 1000 .. 'us')
end

function TestCreateClassBenchmark()
    benchmarkFunction(
        function()
            Utils.Class.CreateClass({}, 'CreateEmpty')
        end,
        100000
    )
end

local testClass = Utils.Class.CreateClass({}, 'EmptyBaseClass')

function TestCreateClassWithBaseClassBenchmark()
    benchmarkFunction(
        function()
            Utils.Class.CreateClass({}, 'CreateEmptyWithBaseClass', testClass)
        end,
        100000
    )
end

function TestConstructClassBenchmark()
    benchmarkFunction(testClass --[[@as function]], 100000)
end

function TestDeconstructClassBenchmark()
    local amount = 100000

    local testClasses = {}
    for i = 1, amount, 1 do
        testClasses[i] = testClass()
    end

    benchmarkFunction(function(num)
        local class = testClasses[num]
        Utils.Class.Deconstruct(class)
    end, amount)
end

os.exit(luaunit.LuaUnit.run())
